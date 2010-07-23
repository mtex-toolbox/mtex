function pos = nodePosition(toc,node)

pos = -1;
items = toc.getElementsByTagName('item');
for k=0:items.getLength-1
  if node.isSameNode(items.item(k)),
    pos = k+1;
  end
end
