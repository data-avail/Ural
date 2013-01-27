// Generated by CoffeeScript 1.3.3
(function() {

  $.widget("baio.tree", {
    options: {
      source: null,
      update: null,
      remove: null,
      link: "TreeTag",
      root: null,
      select: false,
      onSelected: null,
      selected: [],
      selectedLink: null,
      editable: true
    },
    _prepareLink: function(srcLink, parent) {
      var link;
      link = $.extend(true, {}, srcLink);
      if (parent == null) {
        parent = this.options.root;
      }
      if (link.filter) {
        _u.replaceFieldVal(link.filter, "$parent", parent);
        if (this.options.selected) {
          _u.replaceFieldVal(link.filter, "$selected", this.options.selected.toString());
        }
      }
      if (link.args) {
        _u.replaceFieldVal(link.args, "$parent", parent);
        if (this.options.selected) {
          _u.replaceFieldVal(link.args, "$selected", this.options.selected.toString());
        }
      }
      return link;
    },
    _load: function(link, parent, res) {
      var req;
      req = {
        link: typeof link === "string" ? link : this._prepareLink(link, parent)
      };
      return this.options.source(req, function(respTags) {
        return res(respTags.map(function(t) {
          return {
            title: t.value,
            isLazy: true,
            key: t.key,
            label: t.label,
            parent: t.parent
          };
        }));
      });
    },
    _tree: function() {
      return $(this.element[0]).dynatree("getTree");
    },
    _focusedNode: function() {
      /*
          nodes = @_tree().getSelectedNodes()
          focused = nodes.filter((f)->f.isFocused())[0]
          focused ?= nodes[0]
          focused ?= @_tree().getActiveNode()
          focused
      */
      return this._tree().getActiveNode();
    },
    _loadSelected: function() {
      var _this = this;
      if (this.options.selectedLink) {
        return this._load(this.options.selectedLink, null, function(res) {
          var node, r, _i, _len, _ref;
          _ref = res.sort(function(a, b) {
            return a.key > b.key;
          });
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            r = _ref[_i];
            node = _this._tree().getNodeByKey(r.parent);
            if (node !== null) {
              node.addChild(r);
            }
          }
          return _this._setSelected();
        });
      } else {
        return this._setSelected();
      }
    },
    _setSelected: function() {
      var node, s, _i, _len, _ref, _results;
      if (this.options.selected) {
        _ref = this.options.selected;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          node = this._tree().getNodeByKey(s);
          if (node) {
            node.activate();
            node.select();
            _results.push(node.focus());
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    },
    _editNode: function(node, onDone) {
      var prevTitle, tree,
        _this = this;
      prevTitle = node.data.title;
      tree = node.tree;
      tree.$widget.unbind();
      $(".dynatree-title").bind("click", function(event) {
        return event.preventDefault();
      });
      $(".dynatree-title", node.span).html("<input id='editNode' value='" + prevTitle + "'>");
      return $("input#editNode").focus().keydown(function(event) {
        var selectionStart;
        switch (event.which) {
          case 27:
            $("input#editNode").val(prevTitle);
            return $(this).blur();
          case 13:
            if (!$("input#editNode").val()) {
              $("input#editNode").val(prevTitle);
            }
            return $(this).blur();
          case 220:
            if (this.value && this.selectionStart !== this.value.length) {
              selectionStart = this.selectionStart;
              this.value = this.value.substring(0, this.selectionStart) + '/' + this.value.substring(this.selectionStart, this.value.length);
              this.selectionStart = selectionStart + 1;
              this.selectionEnd = this.selectionStart;
            } else {
              this.value = this.value + '/';
            }
            return false;
        }
      }).click(function(event) {
        return false;
      }).blur(function(event) {
        var n, val;
        val = $("input#editNode").val();
        if (val && prevTitle !== val) {
          n = _this._convert(node);
          n.value = val;
          return _this.options.update(_this.options.link, n, function(err) {
            if (!err) {
              node.data.key = n.key;
              node.data.label = n.label;
              node.data.parent = n.parent;
              node.setTitle(n.value);
              tree.$widget.bind();
              node.focus();
            }
            if (onDone) {
              return onDone(err);
            }
          });
        } else {
          tree.$widget.bind();
          node.setTitle(prevTitle);
          node.focus();
          if (onDone) {
            return onDone(null);
          }
        }
      });
    },
    __createNode: function(root) {
      var newNode;
      newNode = root.addChild({
        key: -1,
        title: "",
        label: "",
        parent: root.data.key === "_1" ? this.options.root : root.data.key,
        isLazy: true
      });
      newNode.focus();
      return this._editNode(newNode, function(err) {
        if (newNode.data.key === -1) {
          newNode.remove();
          return root.focus();
        }
      });
    },
    _createNode: function(root) {
      var _this = this;
      root.activate();
      if (root.childList === null && !root.isExpanded()) {
        this._onAfterLazyLoading = function(err) {
          _this._onAfterLazyLoading = null;
          if (!err) {
            return _this.__createNode(root);
          }
        };
        return root.expand();
      } else {
        return this.__createNode(root);
      }
    },
    _createSibling: function(node) {
      var root;
      if (node.parent) {
        root = node.parent;
      } else {
        root = $(this.element[0]).dynatree("getRoot");
      }
      return this._createNode(root);
    },
    _moveNode: function(draggedNode, parent, onDone) {
      var n;
      n = this._convert(draggedNode);
      n.parent = parent;
      return this.options.update(this.options.link, n, function(err) {
        return onDone(err);
      });
    },
    _convert: function(node) {
      return {
        key: node.data.key,
        value: node.data.title,
        label: node.data.label,
        parent: node.data.parent ? node.data.parent : this.options.root
      };
    },
    _removeNode: function(node) {
      return this.options.remove(this.options.link, node.data.key, function(err) {
        if (!err) {
          if (node.parent.data.key !== "_1") {
            node.parent.focus();
          } else {
            node.getPrevSibling().focus();
          }
          return node.remove();
        }
      });
    },
    _create: function() {
      var opts,
        _this = this;
      opts = {
        title: "Baio tree",
        onActivate: function(node) {},
        onDeactivate: function(node) {},
        onFocus: function(node) {
          return node.activate();
        },
        onBlur: function(node) {},
        onLazyRead: function(node) {
          return _this._load(_this.options.link, node.data.key, function(res) {
            node.addChild(res);
            node.setLazyNodeStatus(DTNodeStatus_Ok);
            if (_this._onAfterLazyLoading) {
              return _this._onAfterLazyLoading();
            }
          });
        },
        onDblClick: function(node, event) {
          var nodes;
          if (_this.options.select === "single") {
            _this.options.onSelected(_this._convert(node));
          } else {
            nodes = node.tree.getSelectedNodes().map(function(n) {
              return _this._convert(n);
            });
            _this.options.onSelected(nodes);
          }
          return false;
        },
        onKeydown: function(node, event) {
          var nodes;
          switch (event.which) {
            case 13:
              if (_this.options.select === "single") {
                return _this.options.onSelected(_this._convert(node));
              } else if (_this.options.select === "multi") {
                nodes = node.tree.getSelectedNodes().map(function(n) {
                  return _this._convert(n);
                });
                return _this.options.onSelected(nodes);
              } else if (_this.options.editable) {
                _this._createSibling(node);
                return false;
              }
              break;
            case 113:
              if (_this.options.editable) {
                return _this._editNode(node);
              }
              break;
            case 46:
              return true;
            case 45:
              _this._createNode(node);
              return false;
            case 107:
              if (event.shiftKey) {
                _this._createSibling(node);
              } else {
                _this._createNode(node);
              }
              return false;
              /*
                            if node.parent
                              root = node.parent
                            else
                              root = $(@element[0]).dynatree("getRoot")
                          else
                            root = node
                          @_createNode root
                          false
              */

            case 32:
              if (_this.options.select === "multi") {
                node.toggleSelect();
                return false;
              }
          }
        },
        dnd: {
          preventVoidMoves: true,
          onDragStart: function(node) {
            return true;
          },
          onDragEnter: function(node, sourceNode) {
            return true;
          },
          onDrop: function(node, sourceNode, hitMode, ui, draggable) {
            var parent;
            if (hitMode === "over") {
              parent = node.data.key;
            } else {
              parent = node.data.parent ? node.data.parent : null;
            }
            return _this._moveNode(sourceNode, parent, function(err) {
              if (!err) {
                return sourceNode.move(node, hitMode);
              }
            });
          }
        }
      };
      if (this.options.select === "multi") {
        opts.checkbox = true;
        opts.selectMode = 2;
      } else if (this.options.select === "single") {
        opts.checkbox = false;
        opts.selectMode = 1;
      } else {
        opts.checkbox = false;
        opts.selectMode = 0;
      }
      $(this.element[0]).dynatree(opts);
      return this._update(function() {
        var fcrn;
        if (_this.options.selected && _this.options.selected.length) {
          return _this._loadSelected();
        } else {
          fcrn = $(_this.element[0]).dynatree("getRoot").getChildren()[0];
          if (fcrn) {
            return fcrn.focus();
          }
        }
      });
    },
    _update: function(onDone) {
      var _this = this;
      $(this.element[0]).dynatree("getRoot").removeChildren();
      return this._load(this.options.link, null, function(res) {
        $(_this.element[0]).dynatree("getRoot").addChild(res);
        if (onDone) {
          return onDone();
        }
      });
    },
    add: function() {
      var root;
      root = this._focusedNode();
      return this._createNode(root);
    },
    addRoot: function() {
      /*
          root = @_focusedNode()
          if root
            root = root.parent
          else
      */

      var root;
      root = this._tree().getRoot();
      return this._createNode(root);
    },
    remove: function() {
      var root;
      root = this._focusedNode();
      if (root) {
        return this._removeNode(root);
      }
    },
    rename: function() {
      var root;
      root = this._focusedNode();
      if (root) {
        return this._editNode(root);
      }
    }
  });

}).call(this);