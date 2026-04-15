// --------------------------
// A UI Element to be displayed in our fake UI
// --------------------------
funcdef void UIElementSelectCallBack();
class RandoUIElement : ScriptActor
{
	bool isActive;
	bool isDisabled;
	float fovRatio;
	
	kVec3 positionOffset;
	kVec3 forward;
	kVec3 right;
	kVec3 up;
	
	float width;
	float height;
	
	UIElementSelectCallBack @onSelect;
	
	kRenderMeshComponent@ renderMesh;
	
	RandoUIElement(kActor@ actor)
	{
		super(@actor);
		isActive = true;
		fovRatio = 1.0f;
		SetSize(1.0f, 1.0f);
		@renderMesh = self.RenderMeshComponent();
	}
	
	// --------------------------
	// Sets the direction vectors
	void SetOwnerDirections(
		const kVec3 &in forward,
		const kVec3 &in right,
		const kVec3 &in up)
	{
		this.forward = forward;
		this.right = right;
		this.up = up;
	}
	
	// --------------------------
	// Sets the position offset
	void SetPosition(const kVec3 &in positionOffset)
	{
		this.positionOffset = positionOffset;
	}
	
	// --------------------------
	// Sets the size of the element
	void SetSize(const float width, const float height)
	{
		this.width = width;
		this.height = height;
		UpdateScale();
	}
	
	// --------------------------
	// Upgdates the scale based on the width, height, and other constants
	void UpdateScale()
	{
		self.Scale() = (kVec3(width, 1.0f, height) * UI_SCALE) * fovRatio;
	}
	
	// --------------------------
	// Sets the texture to the given index
	void SetTexture(const int textureIndex)
	{
		renderMesh.AltTexture() = textureIndex - 1;
	}
	
	// --------------------------
	// Sets the disabled status of the UI Element
	void SetDisabled(const bool disabled)
	{
		if (disabled != isDisabled)
		{
			isDisabled = disabled;
		}
	}
	
	// --------------------------
	// Whether the element is being moused over
	bool IsMousedOver(const float x, const float y)
	{
		return (
			(x >= positionOffset.x - width && x <= positionOffset.x + width) && 
			(y >= positionOffset.y - height && y <= positionOffset.y + height)
		);
	}
	
	// --------------------------
	// Sets active to false, which will cause it be removed from the ui
	void RemoveOnTick()
	{
		isActive = false;
	}
	
	// --------------------------
	// Performs an action if selected while not disabled
	void OnSelect(const float x, const float y)
	{
		if (!isDisabled)
		{
			onSelect();
		}
	}
	
	// --------------------------
	// Updates the element's position
	void Update(kActor@ player, kVec3 &in position)
	{
		self.Origin() = position + (
		(
			(right * positionOffset.x) + 
			(up * positionOffset.y) + 
			(forward * positionOffset.z)
		) * fovRatio);
		self.Yaw() = player.Yaw();
	}
}