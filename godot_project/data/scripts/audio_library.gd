class_name AudioLibrary

class Entity:
	class Player:
		class Jump:
			static var one = preload("res://data/sounds/player/jump/jump_1.ogg");
			static var two = preload("res://data/sounds/player/jump/jump_2.ogg");
			static var three = preload("res://data/sounds/player/jump/jump_3.ogg");
			static var four = preload("res://data/sounds/player/jump/jump_4.ogg");
			
			static func all() -> Array[AudioStream]:
				return [one, two, three, four];
		
		class FootSteep:
			class Floor:
				static var one = preload("res://data/sounds/footsteep/floor/footsteep_floor_1.ogg");
				static var two = preload("res://data/sounds/footsteep/floor/footsteep_floor_2.ogg");
				static var three = preload("res://data/sounds/footsteep/floor/footsteep_floor_3.ogg");
				static var four = preload("res://data/sounds/footsteep/floor/footsteep_floor_4.ogg");
				
				static func all() -> Array[AudioStream]:
					return [one, two, three, four];
