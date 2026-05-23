import 'dotenv/config';
import mysql from 'mysql2/promise';
import { Client, GatewayIntentBits, EmbedBuilder } from 'discord.js';

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent]
});

const db = await mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  user: process.env.DB_USER || 'samp_user',
  password: process.env.DB_PASS || 'samp_password',
  database: process.env.DB_NAME || 'zynetra_rp'
});

client.once('ready', () => {
  console.log(`Discord bot online as ${client.user.tag}`);
});

client.on('messageCreate', async (msg) => {
  if (msg.author.bot) return;

  if (msg.content === '!server') {
    msg.reply('Zynetra Roleplay server: IP-VPS-KAMU:7777');
  }

  if (msg.content === '!topmoney') {
    const [rows] = await db.query('SELECT username, money FROM users ORDER BY money DESC LIMIT 10');
    const desc = rows.map((r, i) => `${i + 1}. ${r.username} - $${r.money}`).join('\n') || 'Belum ada data.';
    const embed = new EmbedBuilder().setTitle('Top Money Zynetra RP').setDescription(desc);
    msg.reply({ embeds: [embed] });
  }

  if (msg.content.startsWith('!setadmin')) {
    const owner = process.env.OWNER_DISCORD_ID;
    if (owner && msg.author.id !== owner) return msg.reply('Khusus owner.');

    const args = msg.content.split(' ');
    const username = args[1];
    const level = Number(args[2] || 1);

    if (!username) return msg.reply('Format: !setadmin NamaPlayer 1');

    await db.query('UPDATE users SET admin=? WHERE username=?', [level, username]);
    msg.reply(`Admin ${username} diset level ${level}.`);
  }
});

client.login(process.env.DISCORD_TOKEN);
