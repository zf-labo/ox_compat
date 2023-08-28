# ox_compat
## Transform all qb-menus and qb-inputs to ox_lib context & inputs easilly.


**Install:**
1. Add the resource in your resources folder.
2. Remove `qb-menu` and `qb-input` from the resources.
3. Go in `client/qb-menu.lua` and change `qb-inventory` to you inventory name if it's not `qb-inventory`.
4. Add `ensure ox_compat` after all your resources.
5. Restart the server


**Requirements:**
- ox_lib


**Authors:**
- [overextended](https://github.com/overextended) [for ox_lib interfaces & exportHandler function]
- [zf-labo](https://github.com/zf-labo) [for the conversion and compatibility resource]
