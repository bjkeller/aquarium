Authoring Protocols for Aquarium
===

Prerequisites
---
To author a protocol for Aquarium, you should

* Have access to an Aquarium server, preferably a rehearsal server where mistakes don't matter.
* Have access to a github repository that the Aquarium server can see when you choose "Protocols > Under Version Control" from the menu.
* Understand enough about github to be able to create a new file, edit it, and save it.
* Know a bit of the Ruby programming language. Check out the [Ruby Page](https://www.ruby-lang.org/en/) for documentation.


Getting Started
---
Here is very a simple protocol that displays "Hello World!" to the user.

```ruby
class Protocol
  def main
    show {
      title "Hello World!"
    }
  end
end
```

Save this protocol and run it from within Aquarium. It should display a page to the user that says "Hello World!" and a "Next" button. When the user clicks next, the protocol will complete.

The above example illustrates several important aspects shared by all protocols.

First, the code is all wrapped in a class called **Protocol**. Aquarium looks for this class when it starts the protocol. You must define it, otherwise you will get an error when you run the protocol. Of course, you can define other classes and modules as well, and call them whatever you want to call them.

Second, the method **main** is defined within the  **Protocol** class. This method is Aquarium's entry point into your protocol. You can of course define other methods as well. However, the names **main**, **arguments**, and **debug** have special meaning (see below).

Third, **show** is a function made available to your code by Aquarium. It takes a Ruby block (denoted by curly braces, or by **do ... end** if you wish). Within the block, there are a number of functions that are available, including the function **title**, which takes a string as an argument. The **show** function is how you communicate with the user running your protocol. It is a blocking call, meaning that your code stops running until the user clicks "Next" from within Aquarium. You might think of it as simultaneous "puts" and "gets" calls. You can have any number of calls **show** in your code and you can put fairly complex stuff into the show block.

All About Show
===

The **show** function takes a block of code that can call the following functions:

**title s**

Put the string s at the top of the page. Usually only called once in a given call to show.

**note s**

Put the string s in a smaller font on the page. Often called several times.

**warning s**

Put the string s in bold, eye catching font on the page in hopes that the user might notice it and heed your advice.

**bullet s**

Put the string s on the page, with a bullet in front of it, as in a bullet list.

**check s**

Put the string s on the page, with a clickable checkbox in front of it.

**image path**

Display the image pointed to by **path** on the page. The **path** argument should be understood by whatever image server you have configured for your installation of Aquarium.

**get type, opts={}**

Display an input box to the user to obtain data of some kind. If no options are supplied, then the data is stored in a hash returned by the **show** function with a key called something like get_12 or get_13 (for get number 12 or get number 13). The name of the variable name can be specified via the **var** option. A label for the input box can also be specified. As an example,

```ruby
data = show {
  title "An input example"
  get "text", var: "y", label: "Enter a string", default: "Hello World"
  get "number", var: "z", label: "Enter a number", default: 555
}

y = data[:y]
z = data[:z]
```

**select choices, opts={}**

Display a selection of choices for the user. The options are the same as for **get**. For example,

```ruby
data = show {
  title "A Select Example"
  select [ "A", "B", "C" ], var: "choice", label: "Choose something", default: 1
}

choice = data[:choice]
```

You can tell Aquarium to allow the user to select multiple items with the option **multiple: true**. In that case, the resulting data from the user will contain an array of all selected items.

**upload**

To have the user upload files associated with the step, use 

```ruby
show {
  title "Please upload some files"
  upload
}
```

which will insert a button that starts a file upload dialog. If a variable name is included, as in
```ruby
data = show {
  upload var: "myvar"
}

# do something with data[:myvar]
```

then data[:myvar] will be an array of the uploaded files. Each element in the array will look something like

```ruby
{ id: 123, name: "important_data_for_your_science_paper.pdf" }
```

The id refers to the upload id, which you can use to retrieve the upload at some later time. The uploads are also linked to in the log for the protocol.

**separator**

Display a break between other shown elements, such as between two notes.

**item i**

Display information about the item i -- its id, its location, its object type, and its sample type (if any) -- so that the user can find it. See "Items and Samples" below.

**table t**

Display a table represented by the matrix t. For example,

```ruby
show {
  table [ [ "A", "B" ], [ 1, 2 ] ]
}
```

shows a simple 2x2 table. The entries in the table can be strings or  integers, as above, or they can be hashes with more information about what to display. For example,

```ruby
m = [
  [ "A", "Very", "Nice", { content: "Table", style: { color: "#f00" } } ],
  [ { content: 1, check: true }, 2, 3, 4 ]
]

show {
  title "A Table"
  table m
}
```

shows a table with the 0,3 entry has special styling (any css code can go in the style hash) and the 1,0 entry is checkable, meaning the user can click on it and change its background color. This latter function is useful if you are presenting a number of things for the user to do, and want to have them check them off as they do them.

**transfer a, b, routing**

You will need to read about "Collections" below before this function makes sense. The **transfer** function show an interactive transfer display to the user. The arguments **x** and **y** should be collections and **routing** should be an array of routes of the form { from: [a,b], to: [c,d], volume: v }. Here a,b,c, and d are integer indices into the collections a and b respectively. The "volume" key/value pair is in microliters and is optional. If no volume is specified, then it is expected that the user transfer all of the contents of the source well.

Input via Arguments
===
To specify arguments (a.k.a. parameters) to a protocol, define the method **arguments** in the **Protocol** class. The arguments are then available from within the protocol via the **input** method. For example,

```ruby
class Protocol

  def arguments
    { x: 1, y: "name" }
  end

  def main

    x = input[:x]
    y = input[:name]

    show {
    	title "Arguments"
    	note "x = #{x}, y = #{y}"
    }

  end

end
```

The keys in the hash returned by the **arguments** method define the names of the arguments. The default values for the arguments are values in the hash. They are presented to the user as defaults, but the user can overwrite them. Once the protocol starts running, the values passed in by the user are available via the **input** method. For technical reasons, the **input** method is not available from within a show block, so in the above code the arguments are extracted and assigned to local variables so they can be shown to the user.

**Note**: The arguments method merely defines what is displayed to the user when the protocol starts and limits the user to setting only the arguments specified. However, if the protocol is started via a metacol, for example, then the arguments availble via the input method can be ay arbitrary hash or array containing integers, strings, arrays, and other hashes.

Output via Return
===

For a protocol to return values to, for example, the metacol that called it, simply return a value from the main method. Note that in Ruby, methods return whatever value the last line of the method produces. So if you do not explicitly return something you might be returning nonsense. For example, here is a protocol that asks the user for a value and returns that value plus one.

```ruby
class Protocol

  def main

    user_input = show {
      get "number", var: "x", label: "Enter a number", default: 0
    }

    return { y: user_input[:x] + 1 }

  end

end
```

A common pattern in protocols is to merge a hash obtained from the input to the protocol with more infomation. For example,

```ruby
class Protocol

  def main

    x = input

    # Your code here wherein a variable y is computed based on,
    # for example, input obtained from the user as (s)he runs
    # the protocol or sample ids read from the inventory database.

    return x.merge y

  end

end
```

The output of this protocol can then be fed to another protocol that adds even more information to its input.

Items, Objects and Samples
===
The Aquarium inventory is managed via a structured database of Ruby objects with certain relationships, all of shich are available within protocols. The primary inventory objects are as follows.

* **ObjectType**: An object type might be named a "1 L Bottle" or a "Primer Aliquot". If the variable **o** is an ObjectType, then the following methods are available:*
  * o.name - returns the name of the object type, as in "1 L Bottle"
  * o.handler - returns the name that classifies the object type, as in "liquid_media". This name is used by the aquarium UI to categorize object types. The special handler "collection" is used to show that items with this given object type are collections (see below)
* **SampleType**: A sample type might be something like "Primer" or "Yeast Strain". It defines a class of samples that all have the same basic properties. For example, all Primers have a sequence. If **st** is a sample type, then the following methods are available:*
  * st.name - the name of the sample type, as in "Primer"
  * st.fieldnname - the name of the nth field, for n=1..8. Probably not useful directly. See the Sample object.
  * st.fieldntype - the type of the nth field, either "number", "string", "url", or "sample". Se the Sample object for how to use these fields.
* **Sample**: A specific (yet still abstract) sample, not to be confused with a sample type or an item. For example, a primer with a certain sequence and name will have sample type "Primer" and possibly many items in the lab for the given sample. If **s** is a sample, then the following methods are available:
  * s.id - The id of the sample.
  * s.name: The name of the sample. For example, a sample whose SampleType is "Plasmid" might be named "pLAB1".
  * s.sample_type - The sample type of the sample.
  * s.properties - A hash of the form { key1: value1, ..., key8: value8 } where the nth key is named according to the s.sample_type.fieldnname (as a symbol, not a string).
  * s.make_item object_type_name - Returns an item associated with the sample and in the container described by object_type_name The location of the item is determined by the location wizard.
* **Item**: A physical item in the lab. It has an object type and may correspond to a sample, see the examples below. If **i** is an item, then the following methods are available:
  * i.id - the id of the item. Every item in the lab has such an id that can by used to find information about the item (see Finding Items and Samples).
  * i.location - a string describing where in the lab the item can be found.
  * i.object_type - the object type associated with the item.
  * i.sample - the corresponding sample, if any. Some items correspond to samples and some do not. For example, an item whose object type is "1 L Bottle" does not correspond to a sample. An item whose object type is "Plasmid Stock" will have a corresponding sample, whose name might be something like "pLAB1".
  * i.datum - data associated with the item. It can be an arbitrary Ruby value, but is usually a hash.
  * i.datum = x - set the value of the datum associated with the item to x.
  * i.save - if you make changes to an item, you have to call i.save to make sure the changes are saved to the database.
  * i.reload - if the item has changed somehow in the database, this method update **i** so that it has the latest information from the database.
  * i.mark_as_deleted - to delete an item, don't call delete, call this method instead. It actually just hides the item so old job logs that refer to it can still have something to point to.

Note that Items, Samples, SampleTypes, and ObjectTypes inherit from **ActiveRecord::Base** which is a fundamental rails class with documentation [here](http://api.rubyonrails.org/classes/ActiveRecord/Base.html). The methods in this parent class are available from within a protocol, although care should be taken when using them. In general, it is preferable to use those methods discussed here.

Finding Items and Samples
===
To find items and samples in the database, use the **find** method. This method is most easily explained via examples.

```ruby
find(:item, id: 123)
```

This call to **find** returns a list of items whose id is 123. There should be zero or one such item. Just remember that **find** always returns a list.

```ruby
find(:item, sample: { name: "pLAB1" })
```

This call to **find** returns a list of items that correspond to the sample named "pLAB1". If that sample were a plasmid, then the items returned would be all plasmid stocks and E. coli plasmid stocks, etc. with "pLAB1" in them.

```ruby
find(:item, sample: { object_type: { name: "Enzyme Aliquot" }, sample: { name: "ecoRI" } } )
```

This call returns a list of all aliquots of ecoRI.

```ruby
find(:sample, name: "pLAB1")
```

This call returns all samples named "pLAB1". Since names are unique, this call should return zero or one item.

As an example of how one might use the **find** method, supose here is a protocol that tells the user to check that all the 1 kb Ladders are where they are supposed to be.

```ruby
class Protocol

  def main

    ladders = find(:item, sample: { name: "1 kb Ladder" } )

    ladders.each do |ladder|

      data = show {
        title "Item Number #{ladder.id}"
        note "This item should be at location #{ladder.location}"
        select ["Yes", "No"], var: "okay", label: "Is the item in the proper location?"
      }

      show {
        title "Yikes!"
          warning "Do something to find item number #{ladder.id}!!!"
      } unless data[:okay] == "Yes"

    end

  end

end
```

You can also use **find** to get a list of projects names with

```ruby
find(:project,{})
```

which returns a sorted list of all project names.

Taking Items
===

If a protocol has a list called, say, **items** returned by **find**, that does not mean the user of the protocol necessarily has taken those items from their locations and brought them to the bench. To tell the user to take the items, one must call take. The effect is to associate the item with the job running the protocol, until it is released (see below). It also "touches" the item by the job, so that one can later determine that the item was used by the job.

There are several forms of take. To illustrate them, suppose we have a list of items obtained from **find** as follows

```ruby
items = find(:item, { sample: { name: "pLAB1" }, object_type: { name: "Plasmid Stock" } } )
```

The most basic form of take is simply to do

```ruby
take items
```

which silently (i.e. without telling the user) takes the items. One may also tell the user to take them, which shows the user a page that says where the items are.

```ruby
take items, interactive: true
```

If there are more instructions to give the user, you can add an extra **show** block, as in

```ruby
take(items, interactive: true) {
  warning "Do not leave the freezer open too long!"
}
```

Finally, there is a method of taking a long list of items that goes through freezer boxes in a reasonably intelligent way, so as to reduce the number of freezer door openings and closings. This form of take looks like

```ruby
take items, interactive: true,  method: "boxes"
```

which displays a new page to the user for every freezer box required to take the items. A diagram of the freezer box is shown and the user can check the items as (s)he takes them. Any items not in freezer boxes are displayed in a final page that simply lists the remaining items and their locations.

Note that when the protocol is done with the items, it should release them. The simplest form for release is

```ruby
release items
```

More sophisticated patterns for release are shown below.

Producing and Releasing Items
===

To make new items you use either **new_object** or **new_sample**, which both return Items. Typically, these functions are used with the **produce** function so that the items returned are (a) put in the databased with new unique ids and (b) associated with the job (i.e. they are "taken").

**new_object name** - This function takes the name of an object type and makes a new item with that object type. An object type with that name must exist in the database. For example, you might do

```ruby
i = produce new_object "1 L Bottle"
```
which would return a new item in the variable **i**.

**new_sample sample_name, of: sample_type_name, as: object_type_name** - This function takes a sample name and an object type name and makes a new item with that name. For example, you might do

```ruby
j = produce new_sample "pLAB1", of: "Plasmid", as: "Plasmid Stock"
```

which returns a new item in the variable **i** whose object type is "Plasmid Stock", whose corresponding sample is "pLAB1" and whose sample type is "Plasmid".

When a protocol is done with a an item, it should release it. This is done with the release function.

**release item_list, opts={} //optional block//** -- release an item. This function has many forms. Suppose **i** and **j** are items currently ''taken'' by the protocol.

```ruby
release([i,j])
```

This version of release simply release the items i and j (i.e. it marks them as not taken by the job running the protocol).

```ruby
release([i,j],interactive: true)
```

This version calls **show** and tells the user to put the items away, or dispose of them, etc.  Once the user clicks "Next", the items in the list are marked as not taken.

```ruby
release([i,j],interactive: true) {
  warning "Be careful with these items."
}
```

This version also calls **show**, like the previous version, but also adds the **show** code block to the **show** that release does, so that you can add various notes, warnings, images, etc. to the page shown to the user.

Collections
===

A **Collection** is a special kind of **Item** that has a matrix of **Sample** ids associated with it. The matrix is stored in the datum field of the item as in the format { matrix: [ [ ... ], ..., [ ... ] ], ... }. For easy manipulation of such items, Aquarium provides the class Collection, which inherits from Item.

Constructing Collections
---

Collections can be made in a few different ways, either from nothing, from items whose object types have the handler "collection", or by spreading a number of samples accross a new collection.

To make an entirely new collection, use, for example,

```ruby
i = produce new_collection "Gel", 2, 6
```

To promote an item **i** to a collection, use

```ruby
c = collection_from i
```

which creates and takes a new collection object with an empty 2x6 matrix and an object type of "Gel". Note that the object type associated with a collection **must** have its handler set to "collection".

Finally, suppose **fragments** is a list of fragment sample (obtained from a call to **find** for example). You can construct a new collection whose matrix is populated with those samples as in the following example:

```ruby
collections = produce spread sample_list, "Stripwell", 1, 12
```

This call to **spread** returns a list of collections, which is sent to **produce** to take them. In this example, if there were, say, 30 samples in **sample_list**, then the returned list will contain three 1x12 collections with the first two completely, and the last half full. The first sample in the list is associated with the first well of the first collection, and so on.

Collection Methods
---

Collections inherit all of the methods of Item. In addition, there are a few more methods. Suppose **col** is a collection.

**col.apportion r, c** - Sets the matrix for the collection to an empty rxc matrix and saves the collection to the database. Whatever matrix was associated with the collection is lost.

**col.matrix** - Returns the matrix associated with the collection.

**col.matrix = m** - Sets the matrix associated with the collection to the matrix of Sample ids **m**. Whatever matrix was associated with the collection is lost.

**col.associate m** - Sets the matrix associated with the collection to the matrix m where m can be either a matrix of Samples or a matrix of sample ids. Only sample ids are saved to the matrix. Whatever matrix was associated with the collection is lost.

**col.set r, c, s** - Set the [r,c] entry of the matrix to id of the Sample **s**.

**col.next r, c, opts={}** - With no options, returns the indices of the next element of the collections, skipping to the next column or row if necessary. With the option skip_non_empty: true, returns the next non empty indices. Returns nil if [r,c] is the last element of the collection.

**col.dimensions** - Returns the dimensions of the matrix associated with the collection.

**col.num_samples** - Returns the number of non empty slots in the matrix.

**col.non_empty_string** - Returns a string describing the indices of the non empty elements in the collection. For example, the method might return the string "1,1 - 5,9" to indicate that collection contains samples in those indices. Note that the string is adjustd for viewing by the user, so starts with 1 instead of 0 for rows and columns.

Collection Helpers
---

**load_samples headings, ingredients, collections //optional block//**

This helper function displays a table to the user that describes how to load a number of samples into a collection. The argument **headings** is an array of strings that describe how much to transfer of each ingredient. The argument **ingredients** is an array of array of **Items** to be transfered. The argument **collections** is an array of collections. And **block** is an option **show** style block. Note that this function *does not* change the matrix associated with the collection. This is because the sample that is created by combining the ingredients is likely different than the **Samples** associated with the ingredients. For example, the code below shows the user a table that describes how to arrays of templates, forward primers, and reverse primers into a set of stripwell tubes. The stripwells, after a PCR reaction is run, will contain fragment samples, which should be associated with the collections in a separate step.

```ruby
load_samples(
  [ "Template, 1 µL", "Forward Primer, 2.5 µL", "Reverse Primer, 2.5 µL" ],
  [  templates,        forward_primers,          reverse_primers         ],
  stripwells ) {
    note "Load templates first, then forward primers, then reverse primers."
    warning "Use a fresh pipette tip for each transfer."
  }
```

**show : transfer x, y, routing **

One of the functions available within a show is **transfer**. The arguments x and y should be collections, and routing is a list of from, to, volume triples. Volume is optional. As an example, you can do

```ruby
routing = [
  { from: [0,0], to: [0,0], volume: 10 },
  { from: [0,1], to: [1,1] }
]

show do
  title "Transfer"
  transfer x, y, routing
end
```

**transfer sources, destinations, options={} //optional block//**

This powerful method displays a set of pages using the transfer method from show to the user to that describe how to transfer the individual parts of some quantity of source wells to some quantity of destination wells. The routing arguments are computed automatically. For example, suppose you want the user to transfer all the wells in a set of stripwell tubes into the non-empty lanes of a set of gels. Then you might do something like

```ruby
transfer( stripwells, gels ) {
  note "Use a 100 µL pipetter to transfer 10 µL from the PCR results to the gel as indicated."
}
```

**distribute collection, object_type_name, options = {} //optional block//**

This method is the opposite of **load_samples**. It returns an array of new items that are made from the samples in the collection. The object type of the items is defined by the **object_type_name** argument. The only option to the method is **:except**, which should be a list of collection indices to skip. For example, suppose you had a gel with ladder in lanes (1,1) and (2,1) and you wanted to make gel fragments from the lanes. You could do

```ruby
slices = distribute( gel, "Gel Slice", except: [ [0,0], [1,0] ], interactive: true ) {
  title "Cut gel slices and place them in new 1.5 mL tubes"
  note "Label the tubes with the id shown"
}
```

Tasks
===

Tasks are used to store information that can be used as inputs to protocols or metacols. Within a protocol, available tasks can be found with the **find** function. For example, to find all "Daily" tasks that are "ready", do:

```ruby
tasks = find(:task,{task_prototype: {name: "Daily"},status: "ready"})
```

Tasks have associated specifications (see the Aquarum UI) that can be obtained using the spec field, as in

```ruby
task.spec
```
For example, if "Daily" tasks have am field called "warnings" that is set to an array of strings, one could display those warnings as follows.

```ruby
data = show {
  title "Daily Task Warnings"
  task.spec[:warnings].map { |w| warning w }
}
```

Each task has a status field. The possible status fields can be obtained by looking at the task prototype. For example, if **task** is a "Daily" task, its possible status values might be

```ruby
task.task_prototype.status_options # => [ "ready", "running", "done" ]
```

To set a task's status, simply do

```ruby
task.status = "done"
task.save
```

Be sure to **save** your changes to the task so that they are reflected in the database.

Including Other Files
===

To include another file, saved in a github repo that has been liked to your installation of Aquarium, use "needs". For example,

```ruby
needs "Krill/lib/standard"
```

This method is much like Ruby's require, except that it looks in the github repo named "Krill" for a file called "lib/standard". Usually, such included files contain Ruby modules.