--[=[
	@class DatePicker

	An interface for selecting a date from a calendar.

	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/datepicker/dark.png) | ![Light](/StudioComponents/components/datepicker/light.png) |

	This is a controlled component, which means you should pass in an initial date to the `Date`
	prop and a callback value to the `OnChanged` prop which gets called with the new date when
	the user selects one. For example:

	```lua
	local function MyComponent()
		local date, setDate = React.useState(DateTime.now())
		return React.createElement(StudioComponents.DatePicker, {
			Date = date,
			OnChanged = setDate,
		})
	end
	```

	In most cases the desired behavior would be to close the interface once a selection is made,
	in which case you can use the `OnChanged` prop as a trigger for this.
	
	The default size of this component is exposed in [Constants.DefaultDatePickerSize].
	To keep all inputs accessible, it is recommended not to use a smaller size than this.

	This component is not a modal or dialog box (this should be implemented separately).
]=]

local React = require("@pkg/@jsdotlua/react")

local BaseButton = require("./Foundation/BaseButton")
local CommonProps = require("../CommonProps")
local Constants = require("../Constants")

local useTheme = require("../Hooks/useTheme")

type TimeData = {
	Year: number,
	Month: number,
	Day: number,
}

local TITLE_HEIGHT = 28
local OUTER_PAD = 3

local LOCALE = "en-us"
local ARROWS_ASSET = "rbxassetid://11156696202"

--[[
ideas:
- props for minimum and maximum date
- selecting a date range
- localization
]]

local dayShortName = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" }

local function getDayNumberText(day: number): string
	if day > 9 then
		return tostring(day)
	end
	return `{string.rep(" ", 2)}{day}`
end

local function getDaysInMonth(year: number, month: number)
	if month == 1 or month == 3 or month == 5 or month == 7 or month == 8 or month == 10 or month == 12 then
		return 31
	elseif month == 4 or month == 6 or month == 9 or month == 11 then
		return 30
	elseif year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then
		return 29
	end
	return 28
end

-- 1 = monday, 7 = sunday
local function getDayOfWeek(year: number, month: number, day: number): number
	local time = DateTime.fromUniversalTime(year, month, day)
	local dayWeek = tonumber(time:FormatUniversalTime("d", LOCALE)) :: number
	return 1 + (dayWeek - 1) % 7
end

local function DayButton(props: {
	LayoutOrder: number,
	Fade: boolean?,
	Text: string,
	Selected: boolean,
	Disabled: boolean?,
	OnActivated: () -> (),
})
	return React.createElement(BaseButton, {
		LayoutOrder = props.LayoutOrder,
		Selected = props.Selected,
		BackgroundColorStyle = Enum.StudioStyleGuideColor.RibbonButton,
		BorderColorStyle = Enum.StudioStyleGuideColor.RibbonButton,
		TextTransparency = props.Fade and 0.5 or 0,
		Text = props.Text,
		Disabled = props.Disabled,
		OnActivated = props.OnActivated,
	})
end

local function MonthButton(props: {
	Position: UDim2,
	AnchorPoint: Vector2?,
	ImageRectOffset: Vector2,
	Disabled: boolean?,
	OnActivated: () -> (),
})
	local theme = useTheme()
	local hovered, setHovered = React.useState(false)
	local pressed, setPressed = React.useState(false)

	local color = Enum.StudioStyleGuideColor.Titlebar
	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif pressed then
		color = Enum.StudioStyleGuideColor.Button
		modifier = Enum.StudioStyleGuideModifier.Pressed
	elseif hovered then
		color = Enum.StudioStyleGuideColor.Button
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	return React.createElement("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = UDim2.fromOffset(15, 17),
		BorderSizePixel = 0,
		BackgroundColor3 = theme:GetColor(color, modifier),
		[React.Event.Activated] = function()
			if not props.Disabled then
				props.OnActivated()
			end
		end,
		[React.Event.InputBegan] = function(_, input)
			if props.Disabled then
				return
			elseif input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				setPressed(true)
			end
		end :: any,
		[React.Event.InputEnded] = function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				setPressed(false)
			end
		end :: any,
	}, {
		Icon = React.createElement("ImageLabel", {
			Size = UDim2.fromOffset(5, 9),
			Position = UDim2.fromOffset(5, 4),
			BackgroundTransparency = 1,
			Image = ARROWS_ASSET,
			ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
			ImageRectSize = Vector2.new(5, 9),
			ImageRectOffset = props.ImageRectOffset,
			ImageTransparency = if props.Disabled then 0.7 else 0,
		}),
	})
end

--[=[
	@within DatePicker
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field Date DateTime
	@field OnChanged (newDate: DateTime) -> ()
]=]

type DatePickerProps = CommonProps.T & {
	Date: DateTime,
	OnChanged: ((newDate: DateTime) -> ())?,
}

type PageState = {
	year: number?,
	month: number?,
}

local function DatePicker(props: DatePickerProps)
	local theme = useTheme()
	local chosenPage, setChosenPage = React.useState({
		year = nil,
		month = nil,
	} :: PageState)

	local selectedTime = props.Date
	local selectedData = selectedTime:ToUniversalTime() :: TimeData

	local displayTime = props.Date
	if chosenPage.year ~= nil then
		displayTime = DateTime.fromUniversalTime(chosenPage.year, chosenPage.month)
	end

	-- reconcile state when selected date changes
	-- so that we show the correct page
	React.useEffect(function()
		local data = props.Date:ToUniversalTime() :: TimeData
		setChosenPage({
			year = data.Year,
			month = data.Month,
		})
		return function() end
	end, { props.Date })

	local displayData = displayTime:ToUniversalTime() :: TimeData
	local displayYear = displayData.Year
	local displayMonth = displayData.Month

	local daysInMonth = getDaysInMonth(displayYear, displayMonth)
	local lastMonthYear = if displayMonth == 1 then displayYear - 1 else displayYear
	local lastMonth = if displayMonth == 1 then 12 else displayMonth - 1
	local daysInLastMonth = getDaysInMonth(lastMonthYear, lastMonth)

	local daysPrior = getDayOfWeek(displayYear, displayMonth, 1) - 1
	local daysAfter = 7 * 6 - daysInMonth - daysPrior

	-- common-year february starting on a monday (e.g. february 2027)
	-- we display 7 days before, 1-28, then 7 days after
	if daysPrior == 0 and daysAfter == 14 then
		daysPrior = 7
		daysAfter = 7
	end

	local colorModifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		colorModifier = Enum.StudioStyleGuideModifier.Disabled
	end

	local items: { React.ReactNode } = {}
	local index = 1
	for i = 1, 7 do
		items[index] = React.createElement("TextLabel", {
			Text = dayShortName[i],
			LayoutOrder = i,
			Font = Constants.DefaultFont,
			TextSize = Constants.DefaultTextSize,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText, colorModifier),
			BackgroundTransparency = 1,
		})
		index += 1
	end

	local function makeOnActivated(day: number, month: number, year: number)
		return function()
			local newDate = DateTime.fromUniversalTime(year, month, day)
			if props.OnChanged then
				props.OnChanged(newDate)
			end
		end
	end

	for i = 1, daysPrior do
		local day = daysInLastMonth - daysPrior + i
		local month = (displayMonth - 2) % 12 + 1
		local year = if displayMonth == 1 then displayYear - 1 else displayYear

		items[index] = React.createElement(DayButton, {
			Selected = day == selectedData.Day and month == selectedData.Month and year == selectedData.Year,
			Text = getDayNumberText(day),
			LayoutOrder = index,
			Fade = true,
			OnActivated = makeOnActivated(day, month, year),
			Disabled = props.Disabled,
		})
		index += 1
	end

	for i = 1, daysInMonth do
		local day = i
		local month = displayMonth
		local year = displayYear

		items[index] = React.createElement(DayButton, {
			Selected = day == selectedData.Day and month == selectedData.Month and year == selectedData.Year,
			Text = getDayNumberText(day),
			LayoutOrder = index,
			OnActivated = makeOnActivated(day, month, year),
			Disabled = props.Disabled,
		})
		index += 1
	end

	for i = 1, daysAfter do
		local day = i
		local month = displayMonth % 12 + 1
		local year = if displayMonth == 12 then displayYear + 1 else displayYear

		items[index] = React.createElement(DayButton, {
			Selected = day == selectedData.Day and month == selectedData.Month and year == selectedData.Year,
			Text = getDayNumberText(i),
			LayoutOrder = index,
			Fade = true,
			OnActivated = makeOnActivated(day, month, year),
			Disabled = props.Disabled,
		})
		index += 1
	end

	return React.createElement("Frame", {
		Size = props.Size or Constants.DefaultDatePickerSize,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		ZIndex = props.ZIndex,
		LayoutOrder = props.LayoutOrder,
	}, {
		Main = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
		}, {
			Header = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, TITLE_HEIGHT),
				Text = displayTime:FormatUniversalTime("MMMM YYYY", LOCALE),
				Font = Constants.DefaultFont,
				TextSize = Constants.DefaultTextSize,
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, colorModifier),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Titlebar),
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			}, {
				PrevMonth = React.createElement(MonthButton, {
					Disabled = props.Disabled,
					Position = UDim2.fromOffset(4, 6),
					ImageRectOffset = Vector2.new(0, 0),
					OnActivated = function()
						setChosenPage({
							year = displayMonth == 1 and displayYear - 1 or displayYear,
							month = displayMonth == 1 and 12 or displayMonth - 1,
						})
					end,
				}),
				NextMonth = React.createElement(MonthButton, {
					Disabled = props.Disabled,
					Position = UDim2.new(1, -4, 0, 6),
					AnchorPoint = Vector2.new(1, 0),
					ImageRectOffset = Vector2.new(5, 0),
					OnActivated = function()
						setChosenPage({
							year = displayMonth == 12 and displayYear + 1 or displayYear,
							month = displayMonth == 12 and 1 or displayMonth + 1,
						})
					end,
				}),
			}),
			Grid = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 3, 1, -OUTER_PAD),
				Size = UDim2.new(1, -6, 1, -TITLE_HEIGHT - OUTER_PAD * 2),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIGridLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					CellSize = UDim2.new(1 / 7, 0, 1 / 7, 0),
					CellPadding = UDim2.fromOffset(0, 0),
					FillDirectionMaxCells = 7,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
			}, items),
		}),
	})
end

return DatePicker
