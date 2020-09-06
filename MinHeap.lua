--[[
    MinHeap.lua

    Implements a binary min-heap into Lua.

    Copyright (c) 2020 Owen Bartolf

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

--]]

-- Standard metatable object construction syntax.
local MinHeap = {}
MinHeap.__index = MinHeap

---------------------------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------------------------

--[[**
    Standard constructor
**--]]
function MinHeap.new()

    local self = {}
    
    self.internalElementTable = {}
    self.internalValueTable = {}
    self.size = 0

    setmetatable(self, MinHeap)

    return self

end


---------------------------------------------------------------------------------------
-- MIN HEAP HELPER METHODS
---------------------------------------------------------------------------------------

--[[**
    Swaps two elements in the min heap.

    @param firstIndex (number) The first index to swap.
    @param secondIndex (number) The second index to swap.
**--]]
function MinHeap:Swap(firstIndex, secondIndex)

    local temp = self.internalElementTable[firstIndex]
    self.internalElementTable[firstIndex] = self.internalElementTable[secondIndex]
    self.internalElementTable[secondIndex] = temp

    temp = self.internalValueTable[firstIndex]
    self.internalValueTable[firstIndex] = self.internalValueTable[secondIndex]
    self.internalValueTable[secondIndex] = temp

end

--[[**
    Returns the index of the node that represents the given node's parent.

    @param nodeIndex (number) The index of the current node.

    @returns (number) The index of the node that represents the given node's parent.
**--]]
function MinHeap:GetParentIndexOfNode(nodeIndex)
    return math.floor(nodeIndex / 2)
end

--[[**
    Returns the index of the left node of the given node.

    @param nodeIndex (number) The index of the current node.

    @returns (number) The index of the left node of the given node.
**--]]
function MinHeap:GetLeftChildIndexOfNode(nodeIndex)
    return nodeIndex * 2
end

--[[**
    Returns the index of the right node of the given node.

    @param nodeIndex (number) The index of the current node.

    @returns (number) The index of the right node of the given node.
**--]]
function MinHeap:GetRightChildIndexOfNode(nodeIndex)
    return nodeIndex * 2 + 1
end

--[[**
    Returns the index of the child with the smallest value.

    @param nodeIndex (number) The index of the current node.

    @returns (number) The index of the child with the smallest value.
**--]]
function MinHeap:GetMinChildIndex(nodeIndex)

    local leftChildIndex = self:GetLeftChildIndexOfNode(nodeIndex)
    local leftChildValue = self.internalValueTable[leftChildIndex]
    local rightChildIndex = self:GetRightChildIndexOfNode(nodeIndex)
    local rightChildValue = self.internalValueTable[rightChildIndex]

    if rightChildIndex > self.size then
        return leftChildIndex
    elseif leftChildValue > rightChildValue then
        return rightChildIndex
    else
        return leftChildIndex
    end

end

--[[**
    Percolates the given value down the tree until the min heap property
    is not violated. The min heap property states any node's children should be no
    greater than any given node.

    @param index (number) The index of the node whose value should be percolated. 
**--]]
function MinHeap:PercolateDown(index)
    
    local minIndex = self:GetMinChildIndex(index)
    
    -- Edge case: No need to percolate down if at max percolation.
    if index > self.size then return end

    while minIndex <= self.size and self.internalValueTable[index] > self.internalValueTable[minIndex] do
        
        self:Swap(minIndex, index)
        
        index = minIndex
        minIndex = self:GetMinChildIndex(index)
    
    end

end

--[[**
    Percolates the given value down the tree until the min heap property
    is not violated. The min heap property states any node's children should be no
    greater than any given node.

    @param index (number) The index of the node whose value should be percolated. 
**--]]
function MinHeap:PercolateUp(index)

    if index <= 1 then return end -- Edge case: Max percolation at first element.

    local parentIndex = self:GetParentIndexOfNode(index)

    while parentIndex >= 1 and self.internalValueTable[parentIndex] > self.internalValueTable[index] do
        self:Swap(parentIndex, index)
        
        index = parentIndex
        parentIndex = self:GetParentIndexOfNode(index)
    end

end

--[[**
	Removes the given index from the heap and fixes the heap
	through percolation
	
	@param index (number) The index to remove.
**--]]
function MinHeap:DeleteIndex(index)

    -- Cache for performance
    local internalElementTable = self.internalElementTable
    local internalValueTable = self.internalValueTable

    -- Replace index with element at the end of the heap, then percolate to
    -- satisfy property.
    self:Swap(index, self.size)
    internalElementTable[self.size] = nil
    internalValueTable[self.size] = nil

    self.size = self.size - 1 -- Size is now less.

    -- Percolate up if required.
    local parentIndex = self:GetParentIndexOfNode(index)
    if index > 1 and index <= self.size and internalValueTable[index] < internalValueTable[parentIndex] then
        self:PercolateUp(index)
        return
    end

    -- Percolate down if required
    local childIndex = self:GetMinChildIndex(index)
    if childIndex <= self.size and internalValueTable[index] > internalValueTable[childIndex] then
        self:PercolateDown(index)
        return
    end


end

---------------------------------------------------------------------------------------
-- MIN HEAP IMPLEMENTATION
---------------------------------------------------------------------------------------

--[[**
    Adds the value into the heap.

    @param element (Any) Anything; Whatever you want to be tagged by the given value.
    @param value (number) The priority of the above element.
**--]]
function MinHeap:Push(element, value)

    -- ADD TO END
    self.size = self.size + 1 -- Increase size
    self.internalElementTable[self.size] = element
    self.internalValueTable[self.size] = value

    -- PERCOLATE UP
    self:PercolateUp(self.size)

end

--[[**
    Remove the minimum value from the heap and returns it.

    @returns (Any) The element with the least priority.
**--]]
function MinHeap:Pop()

    -- Edge case: If no elements, just return!
    if self.size == 0 then return nil end
    
    -- GET FIRST
    local element = self.internalElementTable[1]
    
    -- DELETE FIRST
    self:DeleteIndex(1)

    return element

end

--[[**
    Return the minimum value of the heap without removing it.
**--]]
function MinHeap:Peek()
    return self.internalElementTable[1]
end

--[[**
    Clears the minheap, removing all of its elements.
**--]]
function MinHeap:Clear()

    -- Release existing tables to GC
    self.internalElementTable = {}
    self.internalValueTable = {}
    self.size = 0

end

---------------------------------------------------------------------------------------

return MinHeap