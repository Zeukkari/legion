#!/bin/bash

echo "$@" | text2wave -o /tmp/result.wav && castnow /tmp/result.wav --device VoiceOfLegion && rm /tmp/result.wav
