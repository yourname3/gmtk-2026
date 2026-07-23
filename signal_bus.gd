extends Node
class_name TheSignalBus

signal move_selected(move: BoardHighlight)

signal piece_moved()
signal piece_started_moving() # Beginning of piece move animation

signal piece_selected(piece: Piece) # for piece-select-only actions

signal card_played(card: Card)
signal card_finished_playing()
