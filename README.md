# IceBreaker

**IceBreaker** is a web application designed to help people **meet, converse, and get to know each other** through a **turn-based card game over a live voice call**. It’s perfect for dating apps, social meetups, or networking platforms. One user creates a room (authenticated), and another can join as a guest. Players take turns revealing conversation cards and talk naturally using voice.

## Features

- **Turn-Based Card Game**: Each player takes turns revealing conversation cards.
- **Real-Time Voice Call**: Built with WebRTC for free, peer-to-peer voice communication.
- **Customizable Question Types**: Fun, deep, flirty, random — set by the room creator.
- **Creator + Guest Flow**: Only the room creator needs an account; the joiner can be a guest.
- **Realtime Updates**: Cards and turns sync instantly using Supabase Realtime.

## Tech Stack

- **Frontend**: HTML / JavaScript (or React / React Native)
- **Backend & Realtime**: [Supabase](https://supabase.com/) (Auth, Realtime Database)
- **Voice Communication**: WebRTC (peer-to-peer)

