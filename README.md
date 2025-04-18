For a C# version of this plugin, see: [Corner Correction C#](https://github.com/Barni228/corner_correction_cs)

## Description

This plugin adds `CornerCharacter2D` Node.
The `CornerCharacter2D` inherits from `CharacterBody2D` and adds movement functions (`move_and_slide_corner`,
`move_and_collide_corner`) that work like the default `move_and_slide` and `move_and_collide`
functions, but with corner correction applied.

## Examples

check the `examples/` directory for examples on how to use this plugin
You can also look at `test/resources/` for another player implementation

## Testing

This plugin is tested using [GUT](https://github.com/bitwes/Gut)

## License

This project is licensed under the terms of the MIT license.
