# App Overview

## Concept
A multilingual Japanese learning app (Manisu Learn) that supports:
- Hiragana
- Katakana
- Kanji
- Words
- Sentences
- Dialogues
- Grammar

Languages per item:
- Japanese
- Romaji
- Hindi
- English

## Key Features
- Learn content using flashcards / reading
- Track learning progress
- Spaced repetition revision system (SM-2)
- Daily review queue
- Smart search (local, fuzzy)
- Library with tag-based filtering
- Category breakdown analytics on home page

## Data Source
- Fully local (Hive database)
- No backend
- JSON data files bundled in assets
- Data versioning with automatic migration on updates

## Data Files
All located in `assets/data/`:
- `hiragana.json`
- `katakana.json`
- `kanji.json`
- `words.json` (~255 entries)
- `sentences.json` (~122 entries)
- `grammars.json`
- `dialogues.json`

## Core Flow
Add Data → Learn → Mark Learned → Revise (SM-2) → Track → Search

## Goal
Build a personal knowledge system for Japanese language learning, targeting Hindi speakers.