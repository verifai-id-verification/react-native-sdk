import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

interface ComboBoxProps {
  items: { label: string, value: string }[];
  selectedValues: string[];
  onSelectionChange: (selectedValues: string[]) => void;
}

const CheckableComboBox = ({ items, selectedValues, onSelectionChange }: ComboBoxProps) => {
  const [isOpen, setIsOpen] = useState(false);

  const handleToggle = () => {
    setIsOpen(!isOpen);
  };

  const handleSelection = (value: string) => {
    const isSelected = selectedValues.includes(value);
    const newSelectedValues = isSelected ? selectedValues.filter(v => v !== value) : [...selectedValues, value];
    onSelectionChange(newSelectedValues);
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity onPress={handleToggle} style={styles.header}>
        <Text style={styles.headerText}>Select Items</Text>
      </TouchableOpacity>
      {isOpen && (
        <View style={styles.itemsContainer}>
          {items.map(item => (
            <TouchableOpacity key={item.value} onPress={() => handleSelection(item.value)} style={styles.item}>
              <Text style={styles.itemText}>{item.label}</Text>
              {selectedValues.includes(item.value) && <Text style={styles.checkmark}>✔</Text>}
            </TouchableOpacity>
          ))}
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    width: '100%',
    borderWidth: 1,
    borderColor: 'gray',
    borderRadius: 4,
    marginBottom: 10,
  },
  header: {
    padding: 10,
    backgroundColor: 'lightgray',
    borderBottomWidth: 1,
    borderBottomColor: 'gray',
  },
  headerText: {
    fontWeight: 'bold',
  },
  itemsContainer: {
    backgroundColor: 'white',
    padding: 10,
  },
  item: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 5,
  },
  itemText: {
    flex: 1,
    marginLeft: 5,
  },
  checkmark: {
    fontWeight: 'bold',
    color: 'green',
  },
});

export default CheckableComboBox;
