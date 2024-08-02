import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import CommandsScreen from './screens/CommandsScreen';
import OutputScreen from './screens/OutputScreen';

import type { RootStackParamList } from './types';

const RootNativeStack = createNativeStackNavigator<RootStackParamList>();

const App = () => {
  return (
    <NavigationContainer>
      <RootNativeStack.Navigator
        screenOptions={{
          headerShadowVisible: false,
          headerBackTitle: 'Back',
        }}
      >
        <RootNativeStack.Screen
          name="Commands"
          component={CommandsScreen}
          options={{ title: '' }}
        />
        <RootNativeStack.Screen
          name="Output"
          component={OutputScreen}
          options={({ route }) => ({ title: route.params.command.title })}
        />
      </RootNativeStack.Navigator>
    </NavigationContainer>
  );
};

export default App;
