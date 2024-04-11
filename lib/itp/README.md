# Item Transfer Protocol
ITP is a way to request items without knowing where they are exactly.
 Say I want to refuel, I could make a request to a public refuel server to deposit 10 coals to the target inventory.
 it should look like this
 ```lua
 itpclient.request(serverid | hostname, timeout):addItem(name, amount)
 ```


## "Pull Item"  Request

pull item  requests lets you ask the server to put item into your depositInventory which looks like 
```lua
request = {
	index = 1
	type = "pull_item",
	depositInventory = "inventoryname",
	items = {
		item1, item2...
	}
}
```
where an Individual item should look like this
```lua
	item1 = {
		name = "minecraft:item",
		amount = 31,
		[otherdetails...] --matching other details
	}
```

## "Pull Item" Response

after the server attempts to deposit the items, it should send a confirmation which has the details of the operation

```lua
response = {
	index = 2
	type = "pull_item",
	items = {
		item1, item2...
	},
	errors = {
		{type = "errortype", message = "message"},
	}
}
```

## "Push Item" Request
push_item request lets you ask the server to let you deposit your items to the server
its looks like
```lua
request = {
	index = 1,
	type = "push_item",
	fromInventory = "inventoryname",
	items = {item1, item2...},
}
```
the response from the server should be a confirmation with the items the server have pulled from fromInventory.

```lua
request = {
	index = 2,
	type = "push_item",
	items = {item1, item2...},
	errors = {
		{type = "errortype", message = "message"},
	}
}
```


