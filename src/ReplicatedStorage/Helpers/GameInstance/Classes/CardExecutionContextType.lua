export type context = {
	getCardData: (self: context) -> any,
	getCaster: (self: context) -> any,
	getBoard: (self: context) -> any, --currently unused
	getNodeAt: (self:context, coordinates: Vector2) -> any,
	getExtraData: (self:context) -> table,
	getTargetGroupFromCardData: (self:context, groupChoice: string) -> table,
	getMainCoordinates: (self:context) -> Vector2,
	setCardData:(self: context, cardData: any) -> ()
}

return {}