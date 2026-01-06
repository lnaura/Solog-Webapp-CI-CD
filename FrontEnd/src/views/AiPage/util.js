
const PrettyJsonViewer = ({ data }) => {
  try {
    const jsonObject = JSON.parse(data);
    const prettyJson = JSON.stringify(jsonObject, null, 2);

    return (
      <pre>
        <code>{prettyJson}</code>
      </pre>
    );
  } catch (error) {
    console.error("JSON 파싱 에러:", error);
    return <pre><code>{data}</code></pre>;
  }
};

export default PrettyJsonViewer;