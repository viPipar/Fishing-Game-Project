extends Node

signal fishing_result(success: bool, payload: Dictionary)

var current_stage: int = 1
var coin: int = 0
var hooking: bool = false
var release: bool = false
var caught: bool = false
