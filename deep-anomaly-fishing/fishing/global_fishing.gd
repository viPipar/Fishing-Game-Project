extends Node

signal fishing_result(success: bool, payload: Dictionary)

var current_stage: int = 1
var coin: int = 0
var hooking: bool = false
var diff: Array = ["easy", "medium", "hard", "impossible", "seriously"]
var release: bool = false
