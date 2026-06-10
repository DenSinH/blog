---
title: "GBA Emulator with Hardware Renderer"
date: 2020-11-29
categories: 
  - "gba"
  - "programming"
image: "images/DSHBA_unlocked.png"
---

After having a lot of fun writing a GBA emulator in C# a while ago, I decided it was too slow for my liking. I took the time to rewrite it in C++ with an added challenge: I wanted to do _all_ rendering on the GPU. I do some minimal parsing of video memory (mostly in OAM, but also some IO registers) to optimize GPU usage a bit, but other than that, the PPU is entirely emulated in shaders!

It runs pretty fast (on my system, i7 2600 and GTX 670 I have reached framerates of over 5 to 10k fps in some menus, generally in game it reaches framerates of 800fps). It can frameskip, although that causes some graphical glitches sometimes because I might not be syncing correctly. The frameskip feature is mainly there to save GPU usage (less data transfer). I noticed this more on lower end hardware (on my laptop with intel HD graphics for example).

As for accuracy: it's fairly accurate, it passes all "sane" AGS tests (so not the prefetch buffer ones, or the ones that require cycle accuracy). It also passes a lot of endrift's test in her mGBA suite.

I spent a lot of time profiling it, checking out the assembly it generated and optimizing based on that. Some major optimizations I made are:

- Templated function handlers

- Faking the pipeline (saving a lot of time spent reading memory on branches and such). I "reflush" the pipeline whenever a write close to PC happens.

- Faster DMAs

- A better scheduler (based on a heap, and it resets its own timer so that I could use a 32 bit int clock instead of a 64 bit one. This might not sound like a big improvement, but it really did save a lot of time)

- Pagetables for memory reads (software fastmem)

- Compiler intrinsics

And on the graphics side, to save resources (and time spent memcpy'ing to buffer video memory), I did some stuff as well:

- Batching up scanlines to whether or not VRAM is "dirty" (writes happened), and only buffering the "dirty" regions of VRAM.

- Object batching/palette batching (basically the same thing but for OAM or palette RAM)

To run the emulator, you need an opengl 3.3 compatible graphics card. It should be cross platform, though I haven't tried that myself, but it works on windows for me.

Anyway, [here is the link to the repository](https://github.com/DenSinH/DSHBA), feel free to check it out and let me know what you think!
