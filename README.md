# Sharkey

`sharkey` is a cute web-based personal bookmarking service.

* **Bookmarking** means it _saves your links_, allows you to _tag them_, arrange
  in _categories_ and, most important of all, _keep track of what you should visit later_.
* **Personal** means _you control your own data_. Everything is stored on your
  computer and _you can import/export/delete as you please_. It is like the anti-social
  cousin of [Delicious][delicious].
* **Web-based** means it runs on your browser. _You don't need an internet connection_,
  though! It doesn't mean you access a site to use it - it runs on _your computer_.
  It just happens that I prefer to make sites instead of designing windows and buttons
  and stuff.
* **Cute** means it has a nice appearance. It comes with _lots of themes_ and you can
  even customize it _with your own themes_ too.

Here's some screenshots for you:

<!-- Add Screenshots -->

As you can see, `sharkey` is a great tool for [tab hoarders][hoard].

### Why would you do that?

If you know me (which I bet you don't) the following sentence will seem familiar:

<blockquote>
<em>Nah, I won't close this tab... I might need it later.
Let's open another one instead</em>
<footer>
- <cite>Me, Always</cite>
</footer>
</blockquote>

Being like this for years leaves a nasty trail - lots of Firefox crashes,
everything getting slow as fuark, computer-restarting paranoia, etc... <br />
And I bet within those 400+ tabs there are _some_ repeated.

Unfortunately most bookmarking services lacked one or another feature;
some were beautiful but didn't had many things; others had 'em but didn't
allow you to control your own data; others were super ugly and some
were very complicated to install.

Well, `sharkey` is an attempt to gather the best things from them.

You should probably check out the [live demo on saruman.link:5678](http://saruman.link:5678/). <br />
Be warned, though, that since it's completely public it might have some
nasty spam or _even worse things_. <br />
But `sharkey` allows you to easily destroy all data so it shouldn't be
that much of an issue.

### How to use

Hey champ, you have to install it first.

### How to install

You can easily fetch and install `sharkey` via _Ruby Gems_. <br />
Look at that:

```bash
$ gem install sharkey-web
```

That command takes a while because it install all it's dependencies.
You can also [grab the gem file here][gem] if you want.

But, hey, if you run that command _right now_ it will probably fail.
That's because you need...

### ...a dependency

`sharkey` requires `sqlite3` - and not just the library that comes with
your distro, no; it needs the fancy development package.

If you're on Ubuntu/Debian the following command should suffice:

```bash
$ sudo apt-get install libsqlite3-dev
```

Other systems may have different names but you get the
picture - install SQLite!

If you're on Windows... Tough luck, I have no idea what you could do. <br />
If you ever figure it out, please contact me so I can replace this
shameful paragraph. <br />
S-sorry, senpai.

### How to use... again

Alright, so you've installed the dependencies and now you have `sharkey`!

Why don't you run it?

```bash
$ sharkey-web
```

This will create the `sharkey`'s web server, launch it on the background
and call your web browser. It should open a new tab (yet another...!) with
that cute interface of the screenshots above.

To kill the process, simply run:

```bash
$ sharkey-web --kill
```

Anyway, go play with it!

Still reading? Go there, I can wait!

### And Then...

Back, already? ...okay

The rest of the document is just some boring technical talk, you should
probably just stick with the _Help_ session on the `sharkey` web interface.

Anyway, good talking to you. See ya!

## Development

Great, now that that they're gone, let's go to what _really_ matters!

`sharkey` is essentially:

* A [Ruby][ruby] program;
* That is a web application, made with [Sinatra][sinatra];
* Encapsulated on a [Vegas][vegas] executable;
* That has a GUI made with HTML5/CSS3/Javascript;
* With a [Bootstrap][bootstrap] layout ([and Bootswatch themes][bootswatch]);
* Made dynamic and fluid with [jQuery][jquery];
* And featuring with tons of plugins (see below);

Now, between you and me, this was my first attempt on developing a web
application. It was a project to learn several web technologies and how to
integrate them. But don't go around telling anyone this!

## Credits

Besides the links above, I have to point out which tools I've used
behind the scenes.

### Tools

* [tux: A console with direct access to Sinatra's internal stuff](https://github.com/cldwalker/tux). I used it all the time to directly access the database and simulate some GET/POST requests.
* [Mousetrap: a nice keyboard helper](http://craig.is/killing/mice). Thanks to it one can use `sharkey` real fast through keyboard shortcuts.
* [jquery.tagcloud](https://github.com/addywaddy/jquery.tagcloud.js), a simple plugin to create... tag clouds.
* [Bootstrap Auto-Hiding Navbar](https://github.com/istvan-ujjmeszaros/bootstrap-autohidingnavbar) - pretty self-explanatory. I like how when you scroll down the navbar hides and when you scroll up it pops up again.

### Links

While developing `sharkey` I bumped into several dead-ends.
These are the people/links who helped me a lot:

* [Sinatra Recipes: DataMapper](http://recipes.sinatrarb.com/p/models/data_mapper?#article)
* [Sam Stern: Making a Simple, Database-Driven website with Sinatra and Heroku](http://samuelstern.wordpress.com/2012/11/28/making-a-simple-database-driven-website-with-sinatra-and-heroku/)
* [wooptoot: File Upload with Sinatra](http://www.wooptoot.com/file-upload-with-sinatra)
* [Random Ruby Thoughts: Upload Files in Sinatra](http://alfuken.tumblr.com/post/874428235/upload-and-download-files-in-sinatra)
* [The Bastards Book of Ruby: Parsing HTML with Nokogiri](http://ruby.bastardsbook.com/chapters/html-parsing/)
* [Unheap: showcase of lots and lots of Javascript stuff](http://www.unheap.com/)

### Notes

* When running this under development (with `rake preview`) the requests
  seems _mother-fricking slow_; that's because of `shotgun` and it's tendency
  to restart the application on each request.

## License

The whole code is released under the *MIT-license*.

Check file `LICENSE.md` for details on what you can and
cannot do with it.

[delicious]:  https://delicious.com/
[hoard]:      http://www.urbandictionary.com/define.php?term=Tab-Hoarder
[gem]:        http://link
[sinatra]:    http://
[ruby]:       https://www.ruby-lang.org/
[vegas]:      http://code.quirkey.com/vegas/
[bootstrap]:  http://getbootstrap.com/
[bootswatch]: http://bootswatch.com/
[jquery]:     http://jquery.com/

