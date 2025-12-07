gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

#ifdef FOLIAGE_V  // Optimized logic for foliage and general blocks
    
    is_foliage = 0.0;

    // We check if the current entity is a type of foliage.
    bool isFoliageEntity = (
        mc_Entity.x == ENTITY_LOWERGRASS ||
        mc_Entity.x == ENTITY_UPPERGRASS ||
        mc_Entity.x == ENTITY_SMALLGRASS ||
        mc_Entity.x == ENTITY_SMALLENTS ||
        mc_Entity.x == ENTITY_LEAVES ||
        mc_Entity.x == ENTITY_SMALLENTS_NW
    );

    vec4 sub_position = gl_ModelViewMatrix * gl_Vertex;
    vec4 position = gbufferModelViewInverse * sub_position;
    
    if (isFoliageEntity) {
        is_foliage = 0.4;

        if (mc_Entity.x != ENTITY_SMALLENTS_NW) {
            vec3 worldpos = position.xyz + cameraPosition;

            // Original logic for calculating the weight of the movement
            float weight = float(gl_MultiTexCoord0.t < mc_midTexCoord.t);

            if (mc_Entity.x == ENTITY_UPPERGRASS) {
                weight += 1.0;
            } else if (mc_Entity.x == ENTITY_LEAVES) {
                weight = .3;
            } else if (mc_Entity.x == ENTITY_SMALLENTS && (weight > 0.9 || fract(worldpos.y + 0.0675) > 0.01)) {
                weight = 1.0;
            }

            weight *= lmcoord.y * lmcoord.y;
            
            // We calculate the DISPLACEMENT and add it to the base position already calculated.
            vec3 wave_offset_world = wave_move(worldpos.xzy) * weight * (0.03 + (rainStrength * .05));
            vec4 wave_offset_clip = gl_ModelViewProjectionMatrix * vec4(wave_offset_world, 0.0);
            
            gl_Position += wave_offset_clip;
        }
    }

#else // Logic for when it is not a shader with foliage (e.g., entities)

    vec4 sub_position = gl_ModelViewMatrix * gl_Vertex;
    #ifndef NO_SHADOWS
        #ifdef SHADOW_CASTING
            vec4 position = gbufferModelViewInverse * sub_position;
        #endif
    #endif
    
#endif

#ifdef EMMISIVE_V
    float is_fake_emmisor = float(mc_Entity.x == ENTITY_F_EMMISIVE);
#endif

gl_Position.xy += taa_offset * gl_Position.w;

#ifndef SHADER_BASIC
    vec4 homopos = gbufferProjectionInverse * vec4(gl_Position.xyz / gl_Position.w, 1.0);
    vec3 viewPos = homopos.xyz / homopos.w;

    #if defined GBUFFER_CLOUDS
        gl_FogFragCoord = length(viewPos.xz);
    #else
        gl_FogFragCoord = length(viewPos.xyz);
    #endif
#endif