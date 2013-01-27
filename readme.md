URAL SPA FRAMEWORK
==================

YEP ANOTHER ONE!

![general scheme](https://raw.github.com/baio/Ural/master/readme/ural_general.jpg)

The reason
----------
It is always a lack of something in the current javascript MVC frameworks. And no clear points to plug own interfaces to them.

@tylerkeating Just looking at the JavaScript MVC landscape. It must be easier to write a new framework than to adopt the patterns of one that exists!

Can't say better.

Objectives
----------

Features
--------
Conventional based
1. All folders should be on their own places (it could be overriden in code)
2. Folder names must begin with Capital letters (couldn't be overriden)
3. The names of controller, model and view must correspond each another (could be overriden)

#Default folders structure

<code>
|--Controllers
   |-twitController.js
|--Models
   |-twit.js
|--Views
   |--Shared
     |--_layout.html
   |--Twit
     |--index.html
     |--item.html
</code>



Workflow
--------

1. Link hashtag is changed

2. Router parse hashtag and invoke controller's action
    <p>
    <code>
    twits/index -> invoke TwitController::index
    </code>
    <p>
    </p>
    <code>
    status/item/10 -> invoke StatusController::item(10)
    </code>
    </p>

3. Controller loads and generates* view corresponded to the controller's action
    <p>
    <code>
    TwitController::index -> Views/Twit/Index.html
    </code>
    </p>
    > - layouts supported
    > - partial views supported

*in other term - aggregate view itslef, layout and contained partial views.

4. Load data from the service and map them to knockout object (viewModel).
    <p>
    <code>
    twits/index -> [GET] http://url/twits
    </code>
    </p>
    <p>
    <code>
    status/item/10 -> [GET] http://url/status/10
    </code>
    </p>

5. Bind knockout object to the view's viewModel.
    Knockout generate resulted client view on the base of the html bindings and loaded data.

>All steps are customized.
>All classes and views are loaded separately and asynchronously via require.js

Plugins
-------

Extensions and overridings of default implementation

Example
-------

Constraints
-----------
Toughly bound to knockoutjs