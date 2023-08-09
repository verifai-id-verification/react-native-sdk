import React, { useState } from 'react';
import { View, Text } from 'react-native';
import { Picker, PickerProps } from '@react-native-picker/picker';

export enum FlowType {
  Local = "Local",
  Api = "Api",
}

interface ComboBoxProps extends PickerProps<FlowType> {
  onValueChange: (value: FlowType, itemIndex: Number) => void;
}

const FlowComboBox: React.FC<ComboBoxProps> = ({ onValueChange }) => {
  const [selectedValue, setSelectedValue] = useState(FlowType.Api);

  const handleValueChange = (value: FlowType, itemIndex: Number) => {
    setSelectedValue(value);
    onValueChange(value, itemIndex);
  };

  return (
    <View style={{ width: 150 }}>
      <Text style={{ fontSize: 17, fontWeight: 'bold' }}>Select flow:</Text>
      <Picker
        selectedValue={selectedValue}
        onValueChange={handleValueChange}
        style={{ width: '100%' }}
      >
        <Picker.Item label={FlowType.Api} value={FlowType.Api} style={{ width: '100%' }} />
        <Picker.Item label={FlowType.Local} value={FlowType.Local} />
      </Picker>
    </View>
  );
};

export default FlowComboBox;
