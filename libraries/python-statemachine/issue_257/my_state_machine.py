from statemachine import StateMachine, State


class MyStateMachine(StateMachine):
    state1 = State('State1', initial=True)
    state2 = State('State2')
    state3 = State('State3', final=True)

    transition12 = state1.to(state2)
    transition23 = state2.to(state3)

    def do_something(self):
        # print('something')
        print('something else')