import React from "react";
import { reactShinyInput } from 'reactR';
import { Histoslider } from 'histoslider';
import { timeFormat } from 'd3-time-format';

const HistosliderInput = ({ configuration, value, setValue }) => {

  const [lastConfig, setLastConfig] = React.useState({});
  React.useEffect(() => setLastConfig(configuration), [configuration]);

  configuration = {...lastConfig, ...configuration};

  /*
  * All of this setDimensions business is just to support responsive
  * (by passing the computed size of the container div to the Histoslider
  * component). Ideally Histoslider would support responsive by itself, but it
  * doesn't.
  */
  const ref = React.useRef(null);
  const [dimensions, setDimensions] = React.useState(null);

  // Register a resize observer which sets state when the parent div size changes.
  React.useEffect(() => {

    const resize_observer = new ResizeObserver((entries) => {
      if (!ref.current) return;
      const { offsetHeight, offsetWidth } = ref.current;
      const title = ref.current.querySelector('.histoslider-title');
      const titleHeight = title ? title.offsetHeight : 0;
      setDimensions({ height: offsetHeight - titleHeight, width: offsetWidth });
    });

    if (ref.current) resize_observer.observe(ref.current);
    return () => {
      resize_observer.disconnect();
    }

  }, [ref]);

  // Use height/width as a style on the parent div (and pass our own computed height/width via state)
  const style = {width: configuration.width, height: configuration.height};

  // When an update occurs, the config's width/height might be missing, so
  // fallback to the ref's width/height. 
  if (!style.width && ref.current) {
    style.width = ref.current.style.width;
  }
  if (!style.height && ref.current) {
    style.height = ref.current.style.height;
  }

  // i.e., the full selection range
  const range = [
     configuration.data[0].x0, 
     configuration.data[configuration.data.length - 1].x
  ];

  // sometimes `value` can be `null` (double-click quickly on a histogram bar), so be careful
  // when determining whether a filter is applied.
  let isFiltered = false;
  if (range && value) {
    isFiltered = range[0] < value[0] || value[1] < range[1];
  }

  // Use state to track the current value so we can 'reset' the selection when "reset" is clicked.
  const [val, setValueState] = React.useState(value);
  React.useEffect(() => setValueState(value), [value]);

  const Title = <div className='histoslider-title'>
    <label className='histoslider-label'>{configuration.label}</label>
    <a className='histoslider-reset link-primary' role='button' onClick={x => { setValueState(range); setValue(range, true) }} style={{display: isFiltered ? null : 'none'}}>Reset</a>
  </div>

  // Wait to render Histoslider until the parent's dimensions are known.
  if (!dimensions) {
    return <div ref={ref} style={style}>{Title}</div>;
  } else {

    // Ideally the user would be able to pass in a custom formatting function (via formatLabelFunction),
    // but I don't think reactR currently supports that.
    // TODO: this requires the following patch to histoslider:
    // https://github.com/samhogg/histoslider/pull/110
    const formatLabelFunction = configuration.isDate ?
      timeFormat(configuration.handleLabelFormat):
      configuration.formatLabelFunction;

    // Ideally we'd use splicing to pass the rest of the configuration, but I
    // couldn't get it to work, so I'm just listing all the props for now
    // https://github.com/samhogg/histoslider/blob/b4ac504/src/components/Histoslider.js#L102-L126
    return <div ref={ref} style={style}>
      {Title}
      <Histoslider 
        data={configuration.data}
        onChange={x => { setValueState(x); setValue(x, true) }}
        selectedColor={configuration.selectedColor}
        unselectedColor={configuration.unselectedColor}
        width={dimensions.width}
        height={dimensions.height}
        selection={val}
        barStyle={configuration.barStyle}
        barBorderRadius={configuration.barBorderRadius || 0}
        barPadding={configuration.barPadding || 1}
        histogramStyle={configuration.histogramStyle}
        sliderStyle={configuration.sliderStyle}
        showOnDrag={configuration.showOnDrag}
        style={configuration.style}
        handleLabelFormat={configuration.handleLabelFormat}
        formatLabelFunction={formatLabelFunction}
        disableHistogram={configuration.disableHistogram}
      />
    </div>;
  }
};

// https://github.com/react-R/reactR/blob/7dccb68a/srcjs/input.js#L36-L71
const inputOptions = {
  type: "histoslider.histoslider",
  ratePolicy: {
    policy: "debounce", 
    delay: 250
  }
}

reactShinyInput('.histoslider', 'histoslider.histoslider', HistosliderInput, inputOptions);