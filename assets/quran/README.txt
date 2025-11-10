Quran Text Files
================

This directory is reserved for future Quran text files.

The app currently uses quran_index.json for surah metadata.

If you want to add full Quran text:

1. Download Quran text from a royalty-free source:
   - Tanzil.net (https://tanzil.net/download/)
   - Quran.com API
   - Other verified Islamic sources

2. Format options:
   - One JSON file per surah (surah_001.json, surah_002.json, etc.)
   - Single combined JSON file (quran_text.json)
   - Plain text format with verse markers

3. Required fields per ayah:
   - surah: Surah number (1-114)
   - ayah: Ayah number
   - text: Arabic text (Uthmani script recommended)
   - page: Page number (optional)
   - juz: Juz number (optional)

4. Update QuranRepository to load text files

Example JSON structure:
{
  "surah": 1,
  "ayahs": [
    {"number": 1, "text": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"},
    {"number": 2, "text": "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ"}
  ]
}

Note: Always verify the authenticity and accuracy of Quran text from trusted sources.
