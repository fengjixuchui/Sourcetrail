#ifndef QT_CODE_FILE_SINGLE_H
#define QT_CODE_FILE_SINGLE_H

#include <deque>
#include <map>

#include <QFrame>

#include "utility/file/FilePath.h"
#include "utility/TimeStamp.h"

#include "qt/element/QtCodeNavigateable.h"

class QLabel;
class QPushButton;
class QtCodeArea;
class QtCodeFileTitleButton;
class QtCodeNavigator;

class QtCodeFileSingle
	: public QFrame
	, public QtCodeNavigateable
{
	Q_OBJECT

public:
	QtCodeFileSingle(QtCodeNavigator* navigator, QWidget* parent = nullptr);
	virtual ~QtCodeFileSingle();

	void clearFile();
	void clearCache();

	// QtCodeNaviatebale implementation
	virtual QAbstractScrollArea* getScrollArea() override;

	virtual void addCodeSnippet(const CodeSnippetParams& params) override;

	virtual void requestFileContent(const FilePath& filePath) override;
	virtual bool requestScroll(const FilePath& filePath, uint lineNumber, Id locationId, bool animated, bool onTop) override;

	virtual void updateFiles() override;
	virtual void showContents() override;

	virtual void onWindowFocus() override;

	virtual void findScreenMatches(const std::string& query, std::vector<std::pair<QtCodeArea*, Id>>* screenMatches) override;

	const FilePath& getCurrentFilePath() const;
	bool hasFileCached(const FilePath& filePath) const;

	Id getLocationIdOfFirstActiveLocationOfTokenId(Id tokenId) const;

private:
	struct FileData
	{
		FilePath filePath;
		TimeStamp modificationTime;
		bool isComplete;
		std::string title;

		std::shared_ptr<QtCodeArea> area;
	};

	FileData getFileData(const FilePath& filePath) const;
	void setFileData(const FileData& file);

	void updateRefCount(int refCount);

	QtCodeNavigator* m_navigator;

	QWidget* m_areaWrapper;
	FilePath m_currentFilePath;

	QtCodeFileTitleButton* m_title;
	QLabel* m_referenceCount;

	QtCodeArea* m_area;
	std::map<FilePath, FileData> m_fileDatas;
	std::deque<FilePath> m_filePaths;

	bool m_contentRequested;
	bool m_scrollRequested;
};

#endif // QT_CODE_FILE_SINGLE_H
