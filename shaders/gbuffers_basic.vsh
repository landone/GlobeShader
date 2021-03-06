#version 120

#define INVERT_CURVE

#ifndef CURVATURE
	#define CURVATURE			14			//Less is steeper, more is flatter. [ 5 7.5 10 12 14 16 18 20 ]
	#define MAX_DROP			0			//Maximum height things can be curved down. 0 means no limit. [ 0 5 10 20 30 50 75 100 ]
	#define CURVE_MUL			(1.0 / (CURVATURE * CURVATURE))
#endif

#define WAVY_PLANTS

#ifdef WAVY_PLANTS
	#define WAVE_SPEED	1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
	attribute vec3 mc_Entity;
	uniform int worldTime;
	uniform vec3 cameraPosition; 
#endif

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 pos = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
	
	#ifdef INVERT_CURVE
		#if MAX_DROP == 0
			pos.y += (pos.x * pos.x + pos.z * pos.z) * CURVE_MUL;
		#else
			pos.y += min((pos.x * pos.x + pos.z * pos.z) * CURVE_MUL, MAX_DROP);
		#endif
	#else
		#if MAX_DROP == 0
			pos.y -= (pos.x * pos.x + pos.z * pos.z) * CURVE_MUL;
		#else
			pos.y -= min((pos.x * pos.x + pos.z * pos.z) * CURVE_MUL, MAX_DROP);
		#endif
	#endif
	
	#ifdef WAVY_PLANTS
		if (mc_Entity.x == 18) {
			pos.y += sin((worldTime * WAVE_SPEED * 0.15)+(pos.x + pos.z + cameraPosition.x + cameraPosition.z)*0.3) * 0.06;
		}
	#endif
	
	gl_Position = gl_ProjectionMatrix * gbufferModelView * pos;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}