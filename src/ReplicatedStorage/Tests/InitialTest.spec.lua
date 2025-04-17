return function()
	it("adds numbers", function()
		local sum = 2 + 2
		expect(sum).to.equal(4)
	end)

	it("fails gracefully", function()
		local str = "hello"
		expect(str:sub(1, 1)).to.equal("h")
	end)
end