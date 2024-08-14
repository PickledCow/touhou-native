extends Control



func display_sign(location):
	$AnimationPlayer.play("swipe")
	match location:
		0:
			$Route209.visible = true
			$MtCoronet.visible = false
			$SpearPillar.visible = false
		1:
			$Route209.visible = false
			$MtCoronet.visible = true
			$SpearPillar.visible = false
		2:
			$Route209.visible = false
			$MtCoronet.visible = false
			$SpearPillar.visible = true
