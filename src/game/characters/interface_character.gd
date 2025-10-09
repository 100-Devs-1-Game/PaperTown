@abstract
class_name ICharacter
extends CharacterBody3D

@abstract func exit_attack_state()
@abstract func change_state(new_state) -> void
@abstract func get_animated_sprite() -> AnimatedSprite3D
@abstract func play_attack_visuals_one(target: ICharacter) -> void
@abstract func play_attack_visuals_two(target: ICharacter) -> void
@abstract func end_attack_visuals_one(target: ICharacter) -> void
@abstract func end_attack_visuals_two(target: ICharacter) -> void
@abstract func play_damaged_visual() -> void
