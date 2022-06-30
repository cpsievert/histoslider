import { reactShinyInput } from 'reactR';
import { Histoslider } from 'histoslider';

const HistosliderInput = ({ configuration, value, setValue }) => {
  return <Histoslider selection={value} data={configuration.data} onChange={x => setValue(x, true)} />;
};

reactShinyInput(
  '.histoslider', 'histoslider.histoslider', HistosliderInput,
  {"ratePolicy": {"policy": "debounce", "delay": 250}}
);
