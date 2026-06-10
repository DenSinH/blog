---
title: "The Algebraic Small Object Argument"
date: 2023-12-12
image: "images/thesis-preview.png"
---

For my thesis I wrote a formalization of the [_Algebraic Small Object Argument_ by Richard Garner](https://arxiv.org/abs/0712.0724). It is a construction in Category Theory, used to generate Natural Weak Factorization Systems. It is a refinement of Quillen's Small Object Argument, which generates Weak Factorization Systems. There is a lot of work in the formalization, over 15000 lines of code. With some slight [adaptations](https://github.com/UniMath/UniMath/pull/1822) and [optimizations](https://github.com/UniMath/UniMath/issues/1855) I contributed it to the [UniMath library](https://github.com/UniMath/UniMath).

At the start of the project, I had to learn how formalization works, so I made my own version of [the Natural Number Game in Lean](https://adam.math.hhu.de/#/g/leanprover-community/nng4): check out the [Natural Numbers Game I wrote for Coq](http://nng.dennishilhorst.nl)!

#### Abstract

Model categories, introduced by Quillen in 1967, form the cornerstone of modern homotopy theory, providing a language and tools for this branch of mathematics. They consist of two interacting weak factorization systems. Quillen defined a transfinite construction to generate weak factorization systems and thereby model structures on a category, given sufficiently well-behaved classes of maps: the _small object argument_.

Weak factorization systems, lacking algebraic structure, suffer some defects from a categorical point of view. Grandis and Tholen introduced the notion of _natural weak factorization system_ to rectify these issues. Garner pointed out some problematic aspects of the small object argument: that it is not convergent, that it is not related to other known transfinite constructions and that it satisfies no universal property. He refined the small object argument to generate natural weak factorization systems in a more algebraically coherent way.

In this thesis, we elaborate, rephrase and formalize Garner’s ‘algebraic’ small object argument. The formalization is written using the Coq proof checker, using the UniMath library. This is a formalization framework based on Homotopy Type Theory (HoTT). The formalization provides an air-tight confirmation of the theory through computer verified proofs.

We fill in the details in Garner’s construction, add much needed intuition and redefine parts of the construction to be more direct and accessible. We rephrase the theory in more modern language, using constructions like _displayed categories_ and a modern, less strict notion of _monoidal categories_, so that it is fit for formalization. We  
point out the interaction between the theory and the HoTT foundations, and describe some of the constructive issues we come across.

My thesis can be found in the [UU thesis repository](https://studenttheses.uu.nl/handle/20.500.12932/45658).

## Thesis

[Download here](files/FinalVersion.pdf)

## Presentation slides

[Download here](files/PresentationFinalVersion.pdf)
