import React from "react";
import { reactShinyInput } from 'reactR';
import { Histoslider } from 'histoslider';

const HistosliderInput = ({ configuration, value, setValue }) => {

  // Use state/effect in order to pass the computed height/width of the HistosliderInput
  // down to Histoslider (which must take a fixed height/width).
  const ref = React.useRef(null);
  const [dimensions, setDimensions] = React.useState(null);

  // Register a resize observer which sets state when the parent div size changes.
  React.useEffect(() => {

    const resize_observer = new ResizeObserver((entries) => {
      if (!ref.current) return;
      const { offsetHeight, offsetWidth } = ref.current;
      setDimensions({ width: offsetWidth, height: offsetHeight });
    });

    if (ref.current) resize_observer.observe(ref.current);
    return () => {
      resize_observer.disconnect();
    }

  }, [ref]);

  // Use height/width as a style on the parent div (and pass our own computed height/width via state)
  const style = {width: configuration.width, height: configuration.height};

  // Wait to render Histoslider until the parent's dimensions are known.
  if (!dimensions) {
    return <div ref={ref} style={style}></div>;
  } else {
    // This should use splcing, but I couldn't get it to work, so I'm just listing all the props for now
    // https://github.com/samhogg/histoslider/blob/b4ac504/src/components/Histoslider.js#L102-L126
    return <div ref={ref} style={style}>
      <Histoslider 
        data={configuration.data}
        onChange={x => setValue(x, true)}
        selectedColor={configuration.selectedColor}
        unselectedColor={configuration.unselectedColor}
        width={dimensions.width}
        height={dimensions.height}
        selection={value}
        barStyle={configuration.barStyle}
        barBorderRadius={configuration.barBorderRadius}
        barPadding={configuration.barPadding}
        histogramStyle={configuration.histogramStyle}
        sliderStyle={configuration.sliderStyle}
        showOnDrag={configuration.showOnDrag}
        style={configuration.style}
        handleLabelFormat={configuration.handleLabelFormat}
        formatLabelFunction={configuration.formatLabelFunction}
        disableHistogram={configuration.disableHistogram}
      />
    </div>;
  }
};

reactShinyInput(
  '.histoslider', 'histoslider.histoslider', HistosliderInput,
  {"ratePolicy": {"policy": "debounce", "delay": 250}}
);