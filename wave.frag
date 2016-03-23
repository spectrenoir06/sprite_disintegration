extern vec3 iResolution;
extern number iGlobalTime;
// extern vec4 iMouse;


vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){

	vec2 fragCoord = texture_coords * iResolution.xy;

	//Sawtooth function to pulse from centre.
	number offset = (iGlobalTime - floor(iGlobalTime)) / (iGlobalTime);
		number CurrentTime = (iGlobalTime)*(offset);

	vec3 WaveParams = vec3(10.0, 0.8, 0.1 );

	number ratio = iResolution.y/iResolution.x;

	//Use this if you want to place the centre with the mouse instead
	//vec2 WaveCentre = vec2( iMouse.xy / iResolution.xy );

	vec2 WaveCentre = vec2(0.5, 0.5);
	WaveCentre.y *= ratio;

	vec2 texCoord = fragCoord.xy / iResolution.xy;
	texCoord.y *= ratio;
	number Dist = distance(texCoord, WaveCentre);


	color = Texel(texture, texCoord);

	//Only distort the pixels within the parameter distance from the centre
	if ((Dist <= ((CurrentTime) + (WaveParams.z))) &&
	(Dist >= ((CurrentTime) - (WaveParams.z))))
	{
		//The pixel offset distance based on the input parameters
		number Diff = (Dist - CurrentTime);
		number ScaleDiff = (1.0 - pow(abs(Diff * WaveParams.x), WaveParams.y));
		number DiffTime = (Diff  * ScaleDiff);

		//The direction of the distortion
		vec2 DiffTexCoord = normalize(texCoord - WaveCentre);

		//Perform the distortion and reduce the effect over time
		texCoord += ((DiffTexCoord * DiffTime) / (CurrentTime * Dist * 40.0));
		color = Texel(texture, texCoord);

		//Blow out the color and reduce the effect over time
		// color += (color * ScaleDiff) / (CurrentTime * Dist * 40.0);
	}
	return color;
}
