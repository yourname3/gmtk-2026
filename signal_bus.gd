extends Node
class_name TheSignalBus

signal move_selected(move: BoardHighlight)

signal piece_moved()
signal piece_started_moving() # Beginning of piece move animation


signal card_finished_playing()
