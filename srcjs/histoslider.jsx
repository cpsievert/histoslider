import React from "react";
import { reactShinyInput } from 'reactR';
import { Histoslider } from 'histoslider';
import { timeFormat } from 'd3-time-format';

const HistosliderInput = ({ configuration, value, setValue }) => {

  /*
  * All of this useRef/useEffect/useState business is just to support responsive
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
      setDimensions({ width: offsetWidth, height: offsetHeight });
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

  // Wait to render Histoslider until the parent's dimensions are known.
  if (!dimensions) {
    return <div ref={ref} style={style}></div>;
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
      <div style={{display: 'flex', justifyContent: 'center', marginBottom: '-10px'}}>
        {configuration.label ? <label>{configuration.label}</label> : null}
      </div>
      <Histoslider 
        data={configuration.data}
        onChange={x => setValue(x, true)}
        selectedColor={configuration.selectedColor}
        unselectedColor={configuration.unselectedColor}
        width={dimensions.width}
        height={dimensions.height}
        selection={value}
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

// TODO: should we try adding width:100%/height:100% to the uiOutput() container?
//const old_initialize = Shiny.inputBindings["histoslider.histoslider"].initialize;
//Shiny.inputBindings["histoslider.histoslider"].initialize = function(el) {
//  // TODO: probably have to do this recursively :(
//  console.log(el.parentNode);
//  const is_dynamic = el.parentNode.classList.contains('shiny-html-output');
//  if (is_dynamic) {
//    el.style.width = '100%';
//    el.style.height = '100%';
//  }
//}
