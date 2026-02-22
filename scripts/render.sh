#!/usr/bin/env bash
# Offline MIDI-to-WAV rendering script using kuriborosu
# Usage: render.sh <input.mid> <output.wav>
#
# Note: This uses default plugin parameters. Custom presets from the realtime
# mode (config/piano/state.ttl, config/reverb/state.ttl) are not applied
# in offline rendering mode. The default MDA EPiano and Dragonfly Reverb
# parameters are used, which produce a clean Rhodes piano sound.

set -e

MIDI_FILE="$1"
OUTPUT_WAV="$2"

if [ -z "$MIDI_FILE" ] || [ -z "$OUTPUT_WAV" ]; then
    echo "Usage: render.sh <input.mid> <output.wav>"
    echo ""
    echo "Renders a MIDI file through MDA Rhodes Piano + Dragonfly Reverb"
    echo "to produce a WAV audio file (offline, faster than realtime)."
    echo ""
    echo "Note: Uses default plugin parameters (custom presets not yet supported)."
    exit 1
fi

if [ ! -f "$MIDI_FILE" ]; then
    echo "Error: MIDI file not found: $MIDI_FILE"
    exit 1
fi

# Plugin URIs
EPIANO_URI="http://drobilla.net/plugins/mda/EPiano"
REVERB_URI="https://github.com/michaelwillis/dragonfly-reverb"

echo "Rendering: $MIDI_FILE -> $OUTPUT_WAV"
echo "Plugin chain: MDA EPiano -> Dragonfly Reverb"

# Run kuriborosu with the plugin chain
# The MIDI file is processed through EPiano (synth) then Reverb (effect)
kuriborosu "$MIDI_FILE" "$OUTPUT_WAV" "$EPIANO_URI" "$REVERB_URI"

echo "Done: $OUTPUT_WAV"
