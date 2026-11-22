CpNamePlateBorderTemplateMixin = {};

function CpNamePlateBorderTemplateMixin:SetVertexColor(r, g, b, a)
	a = a / self.numLayers;
	for i, texture in ipairs(self.Textures) do
		texture:SetVertexColor(r, g, b, a);
	end
end