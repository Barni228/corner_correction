## Description

This plugin adds `CornerCorrection` Node.
The `CornerCorrection` node will take reference to player, and give you movement methods that work almost the same as default move_and_slide or move_and_collide, but they also corner correct whenever player hits a corner of something.

## Documentation

Just add `CornerCorrection` Node as child of your CharacterBody2D, configure it
and from the character call whatever movement method you want.

## Testing

This plugin is tested using [GUT](https://github.com/bitwes/Gut)

## License

This project is licensed under the terms of the MIT license.
