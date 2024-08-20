# How to define an object and construct it using named parameters?

In this way, using interface and class with the same name

```typescript
interface SimpleStruct {
    name: string;
    age: number;
}

class SimpleStruct {
    name: string = 'default';
    age: number = 200;
    constructor(x?: Partial<SimpleStruct>) {
        Object.assign(this, x);
    }
}

let x = new SimpleStruct({ name: 'John'});
console.log(x)

/*
[LOG]: SimpleStruct: {
  "name": "John",
  "age": 200
} 
*/
```
