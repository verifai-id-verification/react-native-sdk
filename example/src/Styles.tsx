import { StyleSheet } from 'react-native'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    paddingTop: 20,
  },
  buttonContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    margin: 16,
    borderRadius: 4,
    elevation: 3,
    backgroundColor: '#ff576d',
    height: 50,
    width: 300
  },
  spacer: {
    flex: 1,
  },
  footer: {
    backgroundColor: '#001234',
    width: '100%',
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default styles
