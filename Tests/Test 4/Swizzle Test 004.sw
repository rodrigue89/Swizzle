// Tests property setting

objc Box {
	decl val;
}

var box = Box(1);
print(box.val);
box.val = 2;
print(box.val);
