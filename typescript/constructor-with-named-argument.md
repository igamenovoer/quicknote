# How to define a class whose constructor can accept named argument?

see [this](https://constantsolutions.dk/2023/08/03/named-constructors-in-typeScript-constructing-classes-or-objects-using-dart-style/)

It depends on `class-transformer` npm package, install it first.

```bash
npm install class-transformer
```

Then define a base class like this
```typescript
import { plainToInstance } from "class-transformer";

/**
 * @description Base class whose child can be constructed with named arguments
 * see https://constantsolutions.dk/2023/08/03/named-constructors-in-typeScript-constructing-classes-or-objects-using-dart-style/
 * @example
 * class Person extends NamedConstructable<Person> {
 *    name: string;
 *    age: number;
 * }
 * // then you can create an instance of Person like this
 * const person = new Person({name: 'John', age: 30});
 */
export class NamedConstructable<T> {
    constructor(obj: Partial<T> = {}) {
        Object.assign(this, plainToInstance(this.constructor as any, obj));
    }
}
```
