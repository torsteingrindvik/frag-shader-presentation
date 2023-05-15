# Disposition

## frag-0 coords

### What

Cycles between showing normalized coords on R channel for X,
G channel for Y, and both at the same time.

### Why

To show direction of axes, `u_time`, and talk about normalization,
and perhaps color channels.

## frag-1 line, smoothstep

### What

Shows the creation of a line, by multiplication of two smoothsteps.
Also shows the effect of having a larger distance between the low and high values of smoothstep.

### Why

* Allows explaining smoothstep
* Allows talking about colors

## frag-2 animated smoothstep

### What

Shows a smoothstepped X axis vs. the current Y value.

### Why

* Allows explaining smoothstep from another perspective
  * It's interesting to see the same thing from more than one way

## frag-3 lines intersecting, mouse
 
### What

Two intersecting lines, intersecting at the cursor.

### Why

To show user input via `u_mouse`.

## frag-4 UV centering
 
### What

Shows the length from the current frag to the UV origin,
which is centered every other second.

### Why

To setup for UVs in the center for ray marching.

## frag-? ray marching, v1

### What

A simple ray marcher.

* Perspective
* A sphere, or a couple
* No lighting, but cycles between black/white and colors.

### Why

To talk about the algorithm.

## frag-? ray marching, v2

### What

A simple ray marcher, version 2.

* Perspective
* A few more spheres
* Cycle between adding NdotL and speculars

### Why

Can then talk about lighting a bit.

## frag-? ray marching, perspective offset in R, G

### What

Same scene as before, but rendered twice:

1. From `p` for R channel
2. From `p + offset` for G channel

Maybe we get a neat offset effect from this?

## frag-? ray marching a floor

### What

A floor, time varies to be "wavy".

### Why

Show how we can make some "terrain".

## frag-? shadows

### What

Simple hard shadows, then soft shadows.

### Why

Because it's interesting.

## frag-? fog

### What

Some simple fog, followed by advanced depth based fog.

### Why

Looks neat and we haven't tried the more interesting one yet.

## frag-? a noise texture

### What

Shows a noise texture.

### Why

To show we can load a texture into a shader.
Talk a bit about noise.

Preps going back to ray marcher with noise as elevation.

## frag-? dotted moving line

### What

Like frag 1 but dotted/striped moving dots along line, to show
that "things are not always what they seem".

### Why

Gradual fun-increase.

## frag-? circle of confusion

### What

A scene which cycles between two focus points.

### Why

To talk about lenses, focus depth, and to learn it.
Also let's not use a sine to move between the two, something more abrupt (but smooth).
Perhaps use graphtoy first example, `4 = 4*S(0, 0.7, sin(x + t))`, clever.

## frag-? solar flare

### What

Apex Legends ish solar lens effect whatever it's called.

### Why

Looks neat and doable.

## frag-? waves

### What

Re-do the waves we already did in WGSL.

### Why

It looks nice.

## frag-? YUV

### What

Something to do with YUV.

### Why

It was mentioned- we might learn something.

## frag-? Gamma

### What

Something to do with gamma.

### Why

It's important.

## frag-? Ortho

### What

The goal here would be to somehow show how we could move between 
perspective and orthographic. 

### Why

Camera related, looks  _very_ cool in my mind.
