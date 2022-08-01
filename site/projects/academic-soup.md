---
title: Academic Soup
author: Olivia Weston
date: "August 1st 2022"
projectDate: "August 1st 2022"
image: "/images/academic-soup/soup.jpg"
description: "Post detailing my work on the website you're currently browsing."
tags: [computer-science, web-dev, design]
altText: "A top down picture of a butternut squash soup with a small splash of cream"
---

## Summary
I've wanted a personal website that expresses some of my artistic preferences for a long time. After some correspondence with [Michał Gajda](https://github.com/mgajda) I've been given some ideas as to what tech stack to use and he mentioned the [Slick](https://hackage.haskell.org/package/slick) static page generator written in [Haskell](https://www.haskell.org/). With my interests being laden over a lot of theoretical computer science and mathematics, it's only natural I grew to _the language designed by mathematicians_, as some have called it.

Prior to my work on Academic Soup I wasn't very aware of Haskell tools used in production aside from big ones like [Pandoc](https://pandoc.org/). After working with Slick for a bit, I realised how amazing the simplicity is for creating a product in the language. I'm excited to do more things in it.

I decided against a framework-heavy approach, even though I have seen some really impressive websites that utilise a heavy backend. This is in part due to the needless complexity of such a task as well as the fact that I'd likely need to spend a decent chunk of money on server hosting. I would, however, like to give a shoutout to a very cool personal website by a fellow student from Swansea University: Petr Hoffman's [hoffic.dev](https://hoffic.dev/). It definitely pulled me in and made me want to do more backend work.

I find Academic Soup to be a really nice and cute name that represents the collage of my interdisciplinary interests and my approach to them well! 🙂

## Technical details
I started off making vague prototypes in online editors like [JSFiddle](https://jsfiddle.net/) and [LiveWeave](https://liveweave.com/). Soon after coming to some sort of initial concept for how the website would look I started sketching up some UI wireframes on paper and started thinking about how I'd lay out the necessary elements.

As soon as I came to grasp with what I wanted to develop I started working on a separate repository, [academic-soup-front-proto](https://github.com/Surobaki/academic-soup-front-proto) which I used to get a basic (non-templated) frontend index. After this I moved my prototype from the repository, archived the repository and then started working on the [academic-soup](https://github.com/Surobaki/academic-soup) repository.

Once the frontend was in `academic-soup`, I got to work on finishing the index page. After struggling with frontend design for a few days and fiddling around with various CSS properties I nearly gave up and was about to abandon my work on the repository. One thing that really helped me with keeping it simple was [Happy Hues](https://www.happyhues.co/). I used their [palette 15](https://www.happyhues.co/palettes/15) as a guideline for my own website and I recommend trying it out for anyone who feels scared of designing their own colour palette (it's surprisingly difficult)!

After the frontend index was done, the typical, static frontend development mode I was in had to stop and I started looking into my `Main.hs` file containing the build instructions for the website. With this, I copied some code and rewrote boilerplate with different names so my website can accommodate both a *'personal blog'* and *'projects'* (the page you probably got here through).

Once the build rules were finished I got back into developing the static frontend with the [Mustache](https://mustache.github.io/) template engine used by Slick.

### Sources
The cute and lovely soup picture was taken by [@ellaolsson](https://unsplash.com/@ellaolsson), I just retrieved it from [Unsplash](https://unsplash.com/photos/fxJTl_gDh28).

The fonts for this website are taken from Google Fonts (inspect the source code to find them there). For the primary sans-serif font of the website I used [Montserrat](https://fonts.google.com/specimen/Montserrat) and for the cool TeX-like font I used [Ibarra Real Nova](https://fonts.google.com/specimen/Ibarra+Real+Nova).