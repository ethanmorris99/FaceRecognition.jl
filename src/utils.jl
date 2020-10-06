

function memoize_maker(func)
	local cache = Dict()
	f(x...) = get!(cache, x, () => func(x...))
end
