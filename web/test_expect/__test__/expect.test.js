describe(
  'expect',
  () => {
    it(
        'assert asymmetric matcher existent objectContainingAsyMatch', 
        () => {
            result = { bar: {"foo": 'baz'} };
            expectation = expect.objectContaining({ foo: expect.any(String) });

            expect(result).toEqual(expectation);
        }
    );
  }
);