-- The header used this style without defining it; keep the accent explicit.
local s_green = ui.Style():fg("#a6d189")

Header = {
	_id = "header",
}

function Header:new(area, tab)
	return setmetatable({
		_area = area,
		_tab = tab,
		_current = tab.current,
	}, { __index = self })
end

function Header:flags()
	local cwd = self._current.cwd
	local filter = self._current.files.filter
	local finder = self._tab.finder

	local t = {}
	if cwd.spec.is_search then
		t[#t + 1] = string.format("search: %s", cwd.spec.domain)
	end
	if filter then
		t[#t + 1] = string.format("filter: %s", filter)
	end
	if finder then
		t[#t + 1] = string.format("find: %s", finder)
	end
	return #t == 0 and "" or " (" .. table.concat(t, ", ") .. ")"
end

function Header:chip()
	local selected = #self._tab.selected
	local yanked = selected > 0 and 0 or #cx.yanked

	if selected > 0 then
		return {
			" " .. selected .. " ",
			th.mgr.count_selected
		}
	elseif yanked <= 0 then
		return nil
	elseif cx.yanked.is_cut then
		return {
			" " .. yanked .. " ",
			th.mgr.count_cut
		}
	else
		return {
			" " .. yanked .. " ",
			th.mgr.count_copied
		}
	end
end

function Header:redraw()
	local area = self._area
	if area.h < 1 or area.w < 3 then
		return {}
	end

	local chip = self:chip()
	local cw = chip and ui.width(chip[1]) or 0

	local pad = 1
	local x = area.x + 1
	local avail = math.max(0, area.w - x - pad - (cw > 0 and (cw + 1) or 0))
	local path = ui.truncate(
		ya.readable_path(tostring(self._current.cwd)) .. self:flags(),
		{
			max = avail,
			rtl = true
		}
	)
	local pw = ui.width(path)

	local chip_w = math.min(area.w - x, pw + pad + (cw > 0 and (cw + 1) or 0) + 1)

	local s_chip = ui.Style():bg("#313244")
	local s_path = ui.Style():fg("#cdd6f4")

	local mid = {
		ui.Span(string.rep(" ", pad)):style(s_green),
		ui.Span(path):style(s_path),
	}
	if chip then
		mid[#mid + 1] = ui.Span(" "):style(s_chip)
		mid[#mid + 1] = ui.Span(chip[1]):style(chip[2])
	end

	return {
		ui.Line(mid):style(s_chip):area(
			ui.Rect {
				x = x,
				y = area.y,
				w = chip_w,
				h = 1
			}
		),
	}
end

function Header:reflow() return { self } end

-- Mouse events
function Header:click(event, up) end
function Header:scroll(event, step) end
function Header:touch(event, step) end

Root.layout = function(self)
	local area = self._area
	self._chunks = ui.Layout()
		:direction(ui.Layout.VERTICAL)
		:constraints({
			ui.Constraint.Length(1),              -- header
			ui.Constraint.Length(Tabs.height()),  -- tabs
			ui.Constraint.Fill(1),                -- panes
			ui.Constraint.Length(1),              -- separator line
			ui.Constraint.Length(1),              -- status bar
		})
		:split(area:pad(ui.Pad.xy(1)))
	self._sep = self._chunks[4]

	-- self._border = ui.Border(ui.Edge.ALL)
	-- 	:area(area)
	-- 	:type(ui.Border.PLAIN)
	-- 	:style(ui.Style():fg("#585b70"))
end

function Root:build()
	self._children = {
		Backdrop:new(self._area),
		Header:new(self._chunks[1], cx.active),
		Tabs:new(self._chunks[2]),
		Tab:new(self._chunks[3], cx.active),
		Status:new(self._chunks[5], cx.active),
		Modal:new(self._area),
	}
end

function Root:redraw()
	local elements = self._base or {}
	for _, child in ipairs(self._children) do
		elements = ya.list_merge(elements, ui.redraw(child))
	end
	-- сплошная линия над статусбаром, как в переключателе окон
	local sep = self._sep
	if sep and sep.w > 0 and sep.h > 0 then
		elements[#elements + 1] = ui.Line(string.rep("─", sep.w))
			:style(ui.Style():fg("#6c7086"))
			:area(sep)
	end
	if self._border then
		elements[#elements + 1] = self._border
	end
	return elements
end
