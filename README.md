# HTML Elements in Ruby

This is just an experiment on what parsing out custom HTML elements in Ruby might look like, similar to how the custom HTML elements are done in something similar to Laravel's Blade.

Goals if one should exist:

- Not conflict with existing elements or native custom elements
- Be reasonably fast
- Preserve line numbers where stacktraces matter

## Using regular expressions

Using a regular expression to parse HTML runs the risk of summoning [Zalgo][zalgo], but for simple scenarios it might be OK.

This is how it's done in Laravel's [Blade][blade]. I'm not a huge fan of the approach (especially of the regular expressions in Blade) but if the expression is simple enough to understand it's OK.


## Building an AST

Elixir's HEEX appears to tokenize the [HTML][heex] and then transform it. I can see this being better long-term at the potential expense of higher initial effort.


## Tilt pipeline

I think this would make sense as part of a Tilt pipeline. An example (pipeline.rb)[pipeline.rb]) is included.


## Regular expressions + gsub vs Regular expressions + StringScanner

The [regular expression + gsub approach][1] is shorter, but I don't see it scaling if the elements became more complex.

The [StringScanner][2] approach feels like it would decompose easier if more functionality was necessary.

I expected the StringScanner approach to be faster but it was actually slower than the gsub approach. I haven't looked into why.

## Using another library

The project [Selma][selma] is interesting, and is a wrapper around [lol-html][lol-html] which is also interesting.

I tried Selma but it wouldn't accept a tag with a colon in it.


[blade]: https://github.com/laravel/framework/blob/769f00ba71de3b3cbbb271e9f34a019b584982c9/src/Illuminate/View/Compilers/ComponentTagCompiler.php#L104-L158
[heex]: https://github.com/phoenixframework/phoenix_live_view/blob/5ea624b5323e1f9791f4c056db223d952ecc3e0e/lib/phoenix_live_view/tokenizer.ex#L148-L156
[1]: re_scanner.rb
[2]: scanner.rb
[zalgo]: https://stackoverflow.com/a/1732454
[selma]: https://github.com/gjtorikian/selma
[lol-html]: https://github.com/cloudflare/lol-html
