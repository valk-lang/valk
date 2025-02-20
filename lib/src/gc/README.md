
# Strategy

```
- loop stack items
> set item stack-hit mark: true
> mark item & loop properties
>> if property is already marked:
>>> set stack-hit mark & add sub-item to stack-hit-list
>>> add item to remark list
>> otherwise: mark sub-item & loop properties
- loop previous stack-items:
> demark recursive, stop if an item has a stack-hit mark
>> note: only loop properties with pipe flag == 1
- loop demark-list:
> same as previous step 
- loop remark-list
> if unmarked: return
> else: mark properties where pipe-flag == 0 
>> set pipe-flag = 1 if property was unmarked
- loop stack-hit-list
> remove stack-hit mark
- reset pools if new memory bytes kept < 95%
- set new gc trigger point
```
